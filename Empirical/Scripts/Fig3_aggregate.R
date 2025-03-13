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
                      plot.title=element_text(hjust=0.5))
colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF", solo = "#A9A9A9")
  

#reformat data
data_sum_group = group_d %>%
  group_by(network) %>%
  summarySE(
    measurevar = "pct_improve_revised"
    , groupvars = c("network")
    , boot.trials = 1000
    , na.rm=T
  )

# plot data

data_sum_group %>%
  mutate(
    network = factor(network, levels=c("solo","decentralized","discussion","centralized"))
    ,network = fct_recode(network, 
                            " Solo"="solo"
                          , " Decentralized"="decentralized"
                          , " Discussion"="discussion"
                          , " Centralized"="centralized"
                          )
    ) %>%
  ggplot(
    aes(x = network, y = pct_improve_revised)
  ) +
  geom_point(size=1) +
  geom_linerange(
    aes(ymax = pct_improve_revised+bootci, ymin= pct_improve_revised-bootci),
    position = position_dodge(width = 0.9)
  ) +
  ggtitle("By Network") +
  guides(shape="none")+
  labs(x="",
       # y="Mean Error Change"
       ) +
  beckertheme +
  scale_fill_manual(values = colors) + 
  ylim(c(0,1)) + geom_hline(yintercept=0.5, linetype="dashed") +
  theme(axis.text.x=element_text(angle=-90, hjust=0, vjust=0.5)) +
  theme(plot.title = element_text(size=12))

ggsave("../Figures/Fig3a.png", width=2.9, height=3.75)
