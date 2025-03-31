# rm(list=ls());gc()
library(ggplot2)
library(tidyverse,warn.conflicts = F, quietly = T)


if(!exists("mysetupvar")){
  source("1a_group_summaries.R")
}
source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")


dataset_N = group_data %>%
  group_by(dataset, network, crowd_improvement) %>%
  mutate(
    , en=n()
  ) %>%
  group_by(network, crowd_improvement, dataset) %>%
  summarize(
    en=unique(en)
  ) %>%
  group_by(network, crowd_improvement) %>%
  summarize(
    tot=sum(en)
  )


options(dplyr.summarise.inform = FALSE)
boot_results = lapply(1:1000, function(x){group_data[sample(1:nrow(group_data), replace=T),] %>%
  group_by(network) %>%
  mutate(
    , tot_d = length(unique(dataset))
  ) %>%
  group_by(dataset, network, crowd_improvement) %>%
  mutate(
    , p=1/(n()*tot_d)
  ) %>%
  group_by(network, crowd_improvement) %>%
  summarize(
    , tot_p=sum(p)

    , pct_improve_revised_unweighted = mean(pct_improve_revised, na.rm=T)
    , pct_not_worse_unweighted = mean(pct_not_worse, na.rm=T)
    
    , pct_improve_revised = sum(pct_improve_revised*p, na.rm=T)
    , pct_not_worse = sum(pct_not_worse*p, na.rm=T)
  ) 
}) %>%
  do.call(rbind, .) %>%
  group_by(network, crowd_improvement) %>%
  summarize(
    n=n()
   
    , pct_improve_revised_unweighted_se = sd(pct_improve_revised_unweighted)
    , pct_not_worse_unweighted_se = sd(pct_not_worse_unweighted)
    
    , pct_improve_revised_se = sd(pct_improve_revised)
    , pct_not_worse_se = sd(pct_not_worse)
    
  )





mean_results = group_data %>%
  group_by(network) %>%
  mutate(
    , tot_d = length(unique(dataset))
  ) %>%
  group_by(dataset, network, crowd_improvement) %>%
  mutate(
    , p=1/(n()*tot_d)
  ) %>%
  group_by(network, crowd_improvement) %>%
  summarize(
    , tot_p=sum(p)
    
    , pct_improve_revised_unweighted = mean(pct_improve_revised, na.rm=T)
    , pct_not_worse_unweighted = mean(pct_not_worse, na.rm=T)
    
    , pct_improve_revised = sum(pct_improve_revised*p, na.rm=T)
    , pct_not_worse = sum(pct_not_worse*p, na.rm=T)
  ) 

results=merge(
   mean_results
  , boot_results
  , by=c("crowd_improvement","network")
) %>%
  mutate( 
    , pct_improve_revised_lower = pct_improve_revised-pct_improve_revised_se*1.96
   , crowd_improvement = fct_recode(factor(crowd_improvement)
                                   , "Crowd\nImproved"="TRUE"
                                   , "Crowd\nWorse"="FALSE"
    )
    , network = factor(network, levels=c("solo","centralized","discussion","decentralized"))
    , network = fct_recode(factor(network)
                           , "Solo"="solo"
                           , "Decentralized"="decentralized"
                           , "Discussion"="discussion"
                           , "Centralized"="centralized"
    ),
  )


colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF")
shapes = c(Centralized = 18, Decentralized = 15, Discussion = 19, Solo=1)

results$size=c(2,1,1,1,2,1,1,1)

results %>% 
  ggplot(
    aes(x=crowd_improvement, y=pct_improve_revised, shape = network, size=size)) +
  # scale_color_manual(values=colors) +
  scale_shape_manual(values=shapes) +
  geom_hline(yintercept=0.5, linetype="dashed", color="#AAAAAA") +
  geom_point(position = position_dodge(width=0.5)) +
  geom_errorbar(
    aes(ymin=pct_improve_revised-pct_improve_revised_se*1.96, 
                ymax = pct_improve_revised+pct_improve_revised_se*1.96)
    , size=0.5
    , position = position_dodge(width=0.5)
    , width=0
  ) +
  labs(x="") + 
  guides(size="none")+
  nice_theme() +
  theme(axis.ticks.x = element_blank())+
  scale_y_continuous(
    expand = c(0.025,0)
    , lim=c(0.35,0.89)
    , breaks=seq(0.4, 0.8, by=0.1)
  ) +
  scale_x_discrete( expand = c(0,0.4)) +
  scale_size(range = c(1.2, 2.4))


ggsave("../Figures/Fig3.1_LEFT_raw.png"
       , width = 3.2, height = 2, dpi = 1000)



results %>%
  ggplot(
    aes(x=crowd_improvement, y=pct_not_worse, shape = network, size=size)) +
  # scale_color_manual(values=colors) +
  scale_shape_manual(values=shapes) +
  geom_hline(yintercept=0.5, linetype="dashed", color="#AAAAAA") +
  geom_point(position = position_dodge(width=0.5)) +
  geom_errorbar(
    aes(ymin=pct_not_worse-pct_not_worse_se*1.96, 
                ymax = pct_not_worse+pct_not_worse_se*1.96)
    , position = position_dodge(width=0.5)
    , width=0
    , color="black"
    , size=0.5
  ) +
  labs(x="")+
  nice_theme() +
  theme(axis.ticks.x = element_blank())+
  scale_x_discrete( expand = c(0,0.4)) +
  scale_size(range = c(1.2, 2.4)) +
  scale_y_continuous(
    expand = c(0.025,0)
    , lim=c(0.35,0.89)
    , breaks=seq(0.4, 0.8, by=0.1)
  ) +
  guides(size="none")



ggsave("../Figures/Fig3.2_CENTER_raw.png"
       , width = 3.2, height = 2, dpi = 1000)
