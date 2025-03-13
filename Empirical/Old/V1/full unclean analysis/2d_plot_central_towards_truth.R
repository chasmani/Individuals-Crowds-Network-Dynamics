rm(list=ls());gc()
require(DescTools)
require(tidyverse)
require(ggplot2)

source("Scripts/1b_chat_group_summaries.R")

#######central twards truth plots#########

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

