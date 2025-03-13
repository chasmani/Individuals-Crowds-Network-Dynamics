rm(list=ls());gc()
require(DescTools)
require(tidyverse)
require(ggplot2)
require(ggsci)

source("Scripts/1b_chat_group_summaries.R")
#'This isn't finalised - we should probably switch to mean ind err change
#######central twards truth plots#########


beckertheme =   theme(panel.background=element_rect(fill="white", color="black", size=1.1), 
                      axis.text=element_text(size=rel(1), color="black"), 
                      strip.text=element_text(size=rel(1.1)), 
                      legend.text=element_text(size=rel(1.1)), strip.background=element_blank(),
                      title=element_text(size=rel(1.1)),
                      panel.grid=element_blank(),
                      plot.title=element_text(hjust=0.5))


for (var in unique(group_d$dataset)) {
  sum = group_d %>%
    subset(dataset == var) %>%
    mutate(
      central_twd_truth = ifelse(central_twd_truth, "Toward","Away")
    ) %>% 
    group_by(central_twd_truth) %>%
    summarise(
      individual_improvement = mean(pct_not_worse)
      , group_imrpovement = mean(crowd_not_worse)
    )
  
  sum2 = sum %>% 
    pivot_longer(!central_twd_truth, names_to = "type", values_to = "percentage")
  print(ggplot(sum2, aes(x=central_twd_truth, y=percentage, color=type)) + 
          geom_point() +
    labs(x="Central Node Toward Truth", y="Mean % Not Worse"))
}



######### WORK IN PROGRESS ##############
sum_g = group_d %>%
  mutate(
    central_twd_truth = ifelse(central_twd_truth, "Toward","Away")
  ) %>% 
  group_by(dataset, central_twd_truth) %>%
  summarise(
    individual_improvement = mean(pct_not_worse)
    , group_imrpovement = mean(crowd_not_worse)
  )

sum2 = sum %>% 
  pivot_longer(!central_twd_truth, names_to = "type", values_to = "percentage") %>%
  ggplot(
    aes(x=central_twd_truth, y=percentage, color=type)) + 
  geom_point() +
  labs(x="Central Node Toward Truth", y="Mean % Not Worse") +
  facet_wrap(~dataset) + 
  beckertheme + 
  scale_colour_npg()

