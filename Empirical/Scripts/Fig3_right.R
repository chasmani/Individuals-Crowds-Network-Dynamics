# rm(list=ls());gc()
library(ggplot2)
library(tidyverse,warn.conflicts = F, quietly = T)


if(!exists("mysetupvar")){
  source("1a_group_summaries.R")
  source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")
}



dataset_N = group_d %>%
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
  boot_results = lapply(1:1000, function(x){group_d[sample(1:nrow(group_d), replace=T),] %>%
    # merge(dataset_N, by=c("network", "crowd_improvement")) %>%
    group_by(network) %>%
    mutate(
      , tot_d = length(unique(dataset))
    ) %>%
    group_by(crowd_improvement) %>%
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
      # , pct_improve_revised_unweighted = mean(pct_improve_revised_unweighted)
      # , pct_not_worse_unweighted = mean(pct_not_worse_unweighted)
      # 
      # , pct_improve_revised = sum(pct_improve_revised)
      # , pct_not_worse = sum(pct_not_worse)
     
      , pct_improve_revised_unweighted_se = sd(pct_improve_revised_unweighted)
      , pct_not_worse_unweighted_se = sd(pct_not_worse_unweighted)
      
      , pct_improve_revised_se = sd(pct_improve_revised)
      , pct_not_worse_se = sd(pct_not_worse)
      
    )





mean_results = group_d %>%
  # merge(dataset_N, by=c("network", "crowd_improvement")) %>%
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
    , pct_improve_revised_upper = pct_improve_revised+pct_improve_revised_se*1.96
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

results %>% 
  ggplot(
    aes(x=crowd_improvement, y=pct_improve_revised, shape = network)) +
  # scale_color_manual(values=colors) +
  scale_shape_manual(values=shapes) +
  geom_point(position = position_dodge(width=0.5), size = 1.5, color="#777777") +
  geom_errorbar(
    aes(ymin=pct_improve_revised-pct_improve_revised_se*1.96, 
                ymax = pct_improve_revised+pct_improve_revised_se*1.96)
    , position = position_dodge(width=0.5)
    , width=0
  ) +
  geom_hline(yintercept=0.5, linetype="dashed", color="#333333") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x=""
        # , y="P(Improve | Revise)"
       ) + 
  # facet_wrap(~dataset, scales = "free_y") +
  # geom_blank(aes(y = y_min)) +
  # geom_blank(aes(y = y_max)) +
  ylim(c(0,1))+
  nice_theme() +
  scale_x_discrete( expand = c(0,0.4))


ggsave("../Figures/Fig3Aggregate_revised.png"
       , width = 3.2, height = 2, dpi = 1000)



results %>%
  ggplot(
    aes(x=crowd_improvement, y=pct_not_worse, shape = network)) +
  # scale_color_manual(values=colors) +
  scale_shape_manual(values=shapes) +
  geom_point(position = position_dodge(width=0.5), size = 1, color="#777777") +
  geom_errorbar(
    aes(ymin=pct_not_worse-pct_not_worse_se*1.96, 
                ymax = pct_not_worse+pct_not_worse_se*1.96)
    , position = position_dodge(width=0.5)
    , width=0
    , color="black"
  ) +
  geom_hline(yintercept=0.5, linetype="dashed", color="#333333") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x=""
        # , y="P(Improve | Revise)"
       ) + 
  # facet_wrap(~dataset, scales = "free_y") +
  # geom_blank(aes(y = y_min)) +
  # geom_blank(aes(y = y_max)) +
  ylim(c(0,1))+
  nice_theme() +
  scale_x_discrete( expand = c(0,0.4))



ggsave("../Figures/Fig3Aggregate_notworse.png"
       , width = 3.2, height = 2, dpi = 1000)
