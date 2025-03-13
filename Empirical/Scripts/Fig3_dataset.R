# rm(list=ls());gc()
library(ggplot2)
library(tidyverse,warn.conflicts = F, quietly = T)


if(!exists("mysetupvar")){
  source("1a_group_summaries.R")
}
source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")



beckertheme =   theme(panel.background=element_rect(fill="white", color="black", size=1.1), 
                      axis.text=element_text(size=rel(1), color="black"), 
                      strip.text=element_text(size=rel(1.1)), 
                      legend.text=element_text(size=rel(1.1)), strip.background=element_blank(),
                      title=element_text(size=rel(1.1)),
                      panel.grid=element_blank(),
                      plot.title=element_text(hjust=0.5),
                      aspect.ratio = 1)


data_sum = group_d %>%
  # subset(network != "solo") %>%
  group_by(network, crowd_improvement) %>%
  summarySE(
      measurevar="pct_improve_revised"
    , groupvars = c("dataset", "network", "crowd_improvement")
    , boot.trials = 1000
    , na.rm=T
  )

data_sum_notworse = group_d %>%
  # subset(network != "solo") %>%
  group_by(network, crowd_improvement) %>%
  summarySE(
    measurevar="pct_not_worse"
    , groupvars = c("dataset", "network", "crowd_improvement")
    , boot.trials = 1000
    , na.rm=T
  ) 


  
# manipulating the y axis so each facet changes by the same formula, makes 
# symmetrical spacing on either side of y=0
data_sum = data.table::data.table(data_sum)
data_sum[,y_min := min(pct_improve_revised) * 1.1, by = dataset]
data_sum[,y_max := 0 + abs(min(pct_improve_revised)* 1.1), by = dataset]


colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF")
shapes = c(centralized = 19, decentralized = 19, discussion = 19)

data_sum %>% subset(network != "solo") %>%
  ggplot(
    aes(x=crowd_improvement, y=pct_improve_revised, shape = network, color=dataset)) +
  # scale_color_manual(values=colors) +
  # scale_shape_manual(values=shapes) +
  grafify::scale_color_grafify(palette="okabe_ito")+
  geom_point(position = position_dodge(width=0.75), size = 1.8, alpha = 0.75) +
  geom_linerange(
    aes(ymax = pct_improve_revised+bootci, ymin= pct_improve_revised-bootci),
    position = position_dodge(width = 0.75)
    ) +
  geom_hline(yintercept=0.5, linetype="dashed", color="#333333") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x="Mean Crowd Error: Better or Worse"
       # , y="Mean Individual\n error change"
       ) + 
  # facet_wrap(~dataset, scales = "free_y") +
  geom_blank(aes(y = y_min)) +
  geom_blank(aes(y = y_max)) +
  ylim(c(0,1))+
  nice_theme()

ggsave("../Figures/Fig3Bottom.png"
       , width = 3.2, height = 2, dpi = 1000)



data_sum_notworse %>% subset(network != "solo") %>%
  ggplot(
    aes(x=crowd_improvement, y=pct_not_worse, shape = network, color=dataset)) +
  # scale_color_manual(values=colors) +
  # scale_shape_manual(values=shapes) +
  grafify::scale_color_grafify(palette="okabe_ito")+
  geom_point(position = position_dodge(width=0.75), size = 1.8, alpha = 0.75) +
  geom_linerange(
    aes(ymax = pct_not_worse+bootci, ymin= pct_not_worse-bootci),
    position = position_dodge(width = 0.75)
  ) +
  geom_hline(yintercept=0.5, linetype="dashed", color="#333333") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x="Mean Crowd Error: Better or Worse"
       # , y="Mean Individual\n error change"
  ) + 
  # facet_wrap(~dataset, scales = "free_y") +
  # geom_blank(aes(y = y_min)) +
  # geom_blank(aes(y = y_max)) +
  ylim(c(0,1))+
  nice_theme()

ggsave("../Figures/Fig3Bottom_notworse.png"
       , width = 3.2, height = 2, dpi = 1000)

