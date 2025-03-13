rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(reshape2)
library(sdamr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)

source("1_group_summaries.R")




dataset_list = unique(dat_group$dataset)
dat_group = subset(dat_group, is.finite(mu_ind_change))


for (var in unique(dat_group$dataset)) {
  
  # plot the mean crowd change vs the mean individual change in error for each datatset
  # plot_dat = subset(dat_group, dataset == var) %>%
  #   group_by(trial)
  # print(ggplot(data = plot_dat
  #              , aes(crowd_change_mu, mu_ind_change)) + 
  #         geom_point() + 
  #         ggtitle(paste0(var, ": Individual x Crowd (trial)")) +
  #         geom_hline(yintercept=0, linetype="dashed", color="#333333") + 
  #         geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  #         facet_grid(~network) + 
  #   nice_theme())
  # 
  # plot_dat = subset(dat_group, dataset == var) %>%
  #   group_by(trial)
  # print(ggplot(data = plot_dat
  #              , aes(crowd_change_med, med_ind_change)) + 
  #         geom_point() + 
  #         ggtitle(paste0(var, ": Individual x Crowd (trial)")) +
  #         geom_hline(yintercept=0, linetype="dashed", color="#333333") + 
  #         geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  #         labs(
  #           x="Change in crowd median error", 
  #              y="Median Indiv error change") +
  #         facet_grid(~network) + 
  #         nice_theme())
  # ggsave(paste0("figures/crowd_vs_indiv/no_inf/", var, ".png"))
  
  # plot_med = subset(dat_group, dataset == var) %>%
  # print(ggplot(data = plot_med
  #              , aes(mu_crowd_change, med_ind_change)) + 
  #         geom_point() + 
  #         ggtitle(paste0(var, ": Indiv x Crowd (trial)")) +
  #         geom_hline(yintercept=0, linetype="dashed", color="#333333") + 
  #         geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  #         labs(x="Mean crowd change in error", 
  #              y="Median indv change in error") + 
  #         facet_grid(~network) + 
  #   nice_theme())
  # ggsave(paste0("figures/crowd_vs_indiv/median/", var, ".png"))
  
  # plot_pct_improv = subset(dat_group, dataset == var) %>%
  # print(ggplot(data = plot_pct_improv
  #              , aes(mu_crowd_change, pct_improv)) + 
  #         geom_point() + 
  #         ggtitle(paste0(var, ": Inidividual % Improvement (trial)")) +
  #         geom_hline(yintercept=0.5, linetype="dashed", color="#333333") + 
  #         geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  #         labs(x="Mean crowd change in error", 
  #              y="Percentage of indv improving") + 
  #         facet_grid(~network) + 
  #   nice_theme())
  
  # crowd_summary_plot = dat_group %>%
  #   mutate(
  #     crowd_improvement = mu_crowd_change < 0
  #   ) %>%
  #   print(ggplot(data = crowd_summary_plot
  #                , aes(crowd_improvement, pct_improv)) +
  #           geom_point() +
  #           ggtitle(paste0(var, ": Inidividual % Improvement (trial)")) +
  #           geom_hline(yintercept=0.5, linetype="dashed", color="#333333") +
  #           geom_vline(xintercept=0, linetype="dashed", color="#333333") +
  #           labs(x="Mean Crowd Error: Better or Worse",
  #                y="Percentage of indv improving") +
  #           facet_grid(~network) +
  #           nice_theme())




  #ggsave(paste0("figures/crowd_vs_indiv/med/", var, ".png"))


# plot the mean individual improvement, grouped by quartile
  # plot_quartile = subset(out_dat, dataset == var)
  # print(ggplot(data = plot_quartile,
  #              aes(x=error_quartile, y=delta_err, fill=network, group=network)) +
  #         stat_summary(fun.y="mean", geom="bar", position=position_dodge()) +
  #         ggtitle(paste0(var, " indv error x quartile"))+ 
  #         labs(x="Error Quartile", 
  #              y="Individual Change"))
          #facet_grid(~network))
  # ggsave(paste0("figures/quartiles/no_inf/", var, "_mean_error_change.png"))

# calculate the probability of improving - proportion of each individual who's error < 0 for each dataset/network/error_quartile
  # plot_improvement_likelihood = subset(out_dat, dataset == var) %>%
  #   group_by(network, error_quartile) %>%
  #   summarize(improvement_likelihood = sum(improvement)/n()) %>%
  #   ungroup
  # 
  # print(ggplot( data=plot_improvement_likelihood,
  #               aes(x=error_quartile, y=improvement_likelihood, fill=network, group=network)) +
  #         geom_bar(stat="identity", position = 'dodge') +
  #         ggtitle(paste0(var, " % improve x quartile"))+
  #         labs(x="Error Quartile",
  #              y="Percentage of indv improving"))
          # facet_grid(~network))
  # ggsave(paste0("figures/quartiles/no_inf/", var, "_improvement_likelihood.png"))

}

plot_improvement_likelihood = subset(out_dat, network = "solo") %>%
  group_by(dataset, error_quartile) %>%
  summarize(improvement_likelihood = sum(improvement)/n())





quartile_list = dataset_list[dataset_list %in% c("becker 2017", "becker 2019", "gurcay 2015", "lorenz 2011")]

for (var in quartile_list) {
  # plot the mean individual improvement, grouped by quartile
  plot_quartile = subset(out_dat, dataset == var) %>%
    arrange(network)
  print(ggplot(data = plot_quartile,
               aes(x=error_quartile, y=delta_err, fill=network, group=network)) +
          stat_summary(fun.y="mean", geom="bar", position=position_dodge()) +
          ggtitle(paste0(var, " indv error x quartile"))+
          labs(x="Error Quartile",
               y="Individual Change") +
    nice_theme())

  # ggsave(paste0("figures/quartiles/no_inf/", var, "_mean_error_change.png"))
  
  # calculate the probability of improving - proportion of each individual who's error < 0 for each dataset/network/error_quartile
  plot_improvement_likelihood = subset(out_dat, dataset == var) %>%
    group_by(network, error_quartile) %>%
    summarize(improvement_likelihood = sum(improvement)/n()) %>%
    ungroup %>%
    arrange(network)
  
  print(ggplot( data=plot_improvement_likelihood,
                aes(x=error_quartile, y=improvement_likelihood, fill=network, group=network)) +
          geom_bar(stat="identity", position = 'dodge') +
          ggtitle(paste0(var, " % improve x quartile"))+
          labs(x="Error Quartile",
               y="percentage indiv imrpoving") + 
    nice_theme())

  # ggsave(paste0("figures/quartiles/no_inf/", var, "_improvement_likelihood.png"))
  
  
}


dat_group %>%
  ggplot(
    aes(x=crowd_change_mu, y=crowd_change_med) 
  ) +
  geom_point() + 
  labs(title= "Crowd Change per trial",
       x="Change in crowd MEAN", 
       y="Change in crowd MEDIAN") +
  nice_theme()

dat_group %>%
  ggplot(
    aes(x=mu_ind_change, y=med_ind_change) 
  ) +
  geom_point() + 
  labs(title= "Inidividual Change per trial",
       x="Mean Indiv Error Change", 
       y="Median Indiv Error Change") +
  nice_theme()


#### Example of good plotting theme and saving dimensions ##################

almaa_likelihood = subset(out_dat, dataset == "almaatouq 2020") %>%
  group_by(network, error_quartile) %>% 
  summarize(improvement_likelihood = sum(improvement)/n()) %>%
  ungroup


almaa_likelihood %>%
  ggplot(
              aes(x=error_quartile, y=improvement_likelihood, fill=network, group=network)) +
  geom_bar(stat="identity", position = 'dodge') +
  ggtitle("almaatouq 2020") +
  labs(x="Error Quartile", 
       y="Probability",
       subtitle="Likelihood of individual improvement") +
  nice_theme()

ggsave(paste0("figures/quartiles/", "no format.png"))
ggsave(paste0("figures/quartiles/", "6x5x300.png"), width = 6, height = 5, dpi = 300)


#### PLOTTING PLAYGROUND ############

# scatter plots - percentage of individuals improving vs the crowd performance


improvement_group_dat = dat_group %>%
  group_by(dataset, network) %>%
  mutate(
    improvement = ifelse(med_ind_change < 0, 1, 0)
  ) %>%
  summarise(
    improvement_pct = sum(improvement)/n()
    , crowd_error_change = mean(crowd_change_med)
  )

improvement_group_dat %>% 
  ggplot(
    aes(x=crowd_error_change, y=improvement_pct, color = network)) +
  geom_point() +
  ggtitle("Indiv Improvement (%) x \n change in crowd median") +
  labs(x="Mean crowd change in error", 
       y="Percentage of trials where median \n individual change in error reduced") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") +
  nice_theme()


improvement_group_outcome = dat_group %>%
  group_by(dataset, network) %>%
  mutate(
    improvement = ifelse(med_ind_change < 0, 1, 0)
    , crowd_improvement = crowd_change_med < 0
  ) %>%
  ungroup %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarise(
    improvement_pct = sum(improvement)/n()
    , crowd_error_change = mean(crowd_change_med)
  )

improvement_group_outcome %>% 
  ggplot(
    aes(x=crowd_error_change, y=improvement_pct, color = network)) +
  geom_point() +
  ggtitle("Summarised on trial outcome \n (doubled points)") +
  labs(x="Change in crowd median error", 
       y="Percentage of trials where median \n individual change in error reduced") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") +
  nice_theme()


# by trial 



improvement_trials = out_dat %>%
  #subset(dataset != "almaatouq 2020") %>%    # because almaa has wayyyyy more trials than any other study
  group_by(task, trial, dataset, network) %>%
  summarize(
    truth = unique(truth)
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    , med1 = median(pre_influence)
    , med2 = median(post_influence)
    , crowd_pre_err_mu = abs(log(mu1/truth))
    , crowd_post_err_mu = abs(log(mu2/truth))
    , crowd_pre_err_med = abs(log(med1/truth))
    , crowd_post_err_med = abs(log(med2/truth))
    , crowd_change_mu = crowd_post_err_mu - crowd_pre_err_mu
    , crowd_change_med = crowd_post_err_med - crowd_pre_err_med
    , mu_ind_change = mean(delta_err)
    , med_ind_change = median(delta_err)
    , perc_improv = sum(improvement)/n()
    , group_improvement = ifelse(crowd_change_med < 0, 1, 0)
  ) 

improvement_trials %>%
  ggplot(
    aes(x=crowd_change_med, y=perc_improv, color = network)) +
  geom_point() +
  ggtitle("Proportion of individuals improving\n vs crowd change in error") +
  labs(x="Change in crowd median error", 
       y="% indv improv within trials (median)") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") +
  nice_theme()

zero_improve = improvement_trials %>%
  subset(perc_improv == 0)


improvement_trials_outcome = outlier_dat %>%
  group_by(task, trial, dataset, network) %>%
  summarize(
    truth = unique(truth)
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    , crowd_pre_err = abs(log(mu1/truth))
    , crowd_post_err = abs(log(mu2/truth))
    , mu_crowd_change = crowd_post_err - crowd_pre_err
    , group_improvement = ifelse(mu_crowd_change < 0, 1, 0)
  ) %>%
  ungroup %>%
  group_by(task, trial, dataset, network, group_improvement) %>%
  summarize(
    mu_ind_change = mean(delta_err)
    , perc_improv = sum(improvement)/n()
  ) 


improvement_dat = out_dat %>%
  group_by(dataset, network) %>%
  summarize(
    network = unique(network)
    , truth = unique(truth)
    , N = n()
    , improvement_pct = sum(improvement)/N
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    , crowd_pre_err = abs(log(mu1/truth))
    , crowd_post_err = abs(log(mu2/truth))
    , mu_crowd_change = crowd_post_err - crowd_pre_err
    , mu_ind_change = mean(delta_err)
  ) 

improvement_dat %>%
  ggplot(
    aes(x=mu_crowd_change, y=improvement_pct)) +
  geom_point() +
  ggtitle("Percentage of individual improvement by dataset and network") +
  labs(x="Mean crowd change in error", 
       y="Percentage of indv improving") +
  nice_theme()
  
  

summary_stats = out_dat %>%
  group_by(dataset, network, trial) %>%
  summarise(
    truth = unique(truth)
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    , mu_ind_change = mean(delta_err)
    , N = n()
    ) %>%
  group_by(dataset, network) %>%
  mutate(
    crowd_pre_err = abs(log(mu1/truth))
    , crowd_post_err = abs(log(mu2/truth))
  ) #%>%
  # subset(is.finite(crowd_pre_err) & is.finite(crowd_post_err)) %>%
  # summarise(
  #   mu_crowd_change = mean(crowd_post_err - crowd_pre_err)
  # )


######## CURRENT GRAPHS ###############

dat_group %>%
  group_by(trial) %>%
  ggplot(
    aes(crowd_change_med, med_ind_change)) + 
        geom_point() + 
        ggtitle("Median individual change in error vs crowd change") +
        geom_hline(yintercept=0, linetype="dashed", color="#333333") + 
        geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
        labs(x="Mean crowd change in error", 
             y="Median indv change in error") + 
        facet_grid(network~dataset)


dat_group %>%
  mutate(
    crowd_improvement = crowd_change_mu <= 0
  ) %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarise(
    mean_perc = mean(pct_not_worse)
  ) %>%
  ggplot(
    aes(crowd_improvement, mean_perc, color = network)) +
  geom_point() + 
  # geom_text(aes(label=network),hjust=-.2, vjust=0) +
  ggtitle("Inidividual % INot getting worse")+
  geom_hline(yintercept=0.5, linetype="dashed", color="#333333") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x="MEAN Crowd Error: Better or Worse", 
       y="MEAN % of indv \nnot getting worse per network") + 
  facet_wrap(~dataset) +
  nice_theme()

xxdat_group %>%
  mutate(
    crowd_improvement = crowd_change_med < 0
  ) %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarise(
    mean_change = mean(med_ind_change)
  ) %>%
  ggplot(
    aes(crowd_improvement, mean_change, color = network)) + 
  geom_point() +
  ggtitle("Median ind change vs crowd outcome") +
  geom_hline(yintercept=0.5, linetype="dashed", color="#333333") + 
  labs(x="Median Crowd Error: Better or Worse", 
       y="Median Individual Error Change") + 
  nice_theme()

group_dataset_dat = dat_group %>%
  group_by(dataset, network) %>%
  mutate(
    crowd_improvement = crowd_change_med < 0
  ) %>%
  ungroup %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarise(
    average_median_indv_change = mean(med_ind_change)
  )

quartile_dataset_dat = dat_group %>%
  group_by(dataset, network) %>%
  mutate(
    crowd_quartile = ntile(crowd_change_med, 4)
  ) %>%
  ungroup %>%
  group_by(dataset, network, crowd_quartile) %>%
  summarise(
    average_median_indv_change = mean(med_ind_change)
  )

group_dataset_dat %>% 
  ggplot(
    aes(x=crowd_improvement, y=average_median_indv_change, color=network)) +
  geom_point()+
  ggtitle("Average median individual change\n vs group outcome") +
  labs(x="Crowd improvement", 
       y="Average median individual change") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") +
  nice_theme()

quartile_dataset_dat %>% 
  ggplot(
    aes(x=crowd_quartile, y=average_median_indv_change, color=network)) +
  geom_point() +
  ggtitle("Average median individual change\n vs crowd quartile") +
  labs(x="Outcome of crowd (Quartile)", 
       y="Average median individual change") +
  geom_hline(yintercept=0, linetype="dashed", color="#333333") +
  nice_theme()


group_dat_network = dat_group %>%
  group_by(network) %>%
  mutate(
    crowd_improvement = crowd_change_med < 0
  ) %>%
  ungroup %>%
  group_by(network, crowd_improvement) %>%
  summarise(
    average_median_indv_change = mean(med_ind_change)
  )

group_dat_network %>% 
  ggplot(
    aes(x=crowd_improvement, y=average_median_indv_change, color=network)) +
  geom_point()+
  ggtitle("Average median individual change vs group outcome") +
  labs(x="Outcome of crowd", 
       y="Average median individual change") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") +
  nice_theme()



quartile_dat_network = dat_group %>%
  group_by(network) %>%
  mutate(
    crowd_quartile = ntile(crowd_change_med, 4)
  ) %>%
  ungroup %>%
  group_by(network, crowd_quartile) %>%
  summarise(
    average_median_indv_change = mean(med_ind_change)
  )

quartile_dat_network %>% 
  ggplot(
    aes(x=crowd_quartile, y=average_median_indv_change, color=network)) +
  geom_point() +
  ggtitle("Average median individual change vs group outcome") +
  labs(x="Outcome of crowd", 
       y="Average median individual change") +
  geom_hline(yintercept=0, linetype="dashed", color="#333333") +
  nice_theme()


group_dat_dataset = dat_group %>%
  group_by(dataset) %>%
  mutate(
    crowd_improvement = crowd_change_med < 0
  ) %>%
  ungroup %>%
  group_by(dataset, crowd_improvement) %>%
  summarise(
    average_median_indv_change = mean(med_ind_change)
  )

group_dat_dataset %>% 
  ggplot(
    aes(x=crowd_improvement, y=average_median_indv_change, color=dataset)) +
  geom_point()+
  ggtitle("Average median individual change vs group outcome") +
  labs(x="Outcome of crowd", 
       y="Average median individual change") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") +
  nice_theme()



quartile_dat_dataset = dat_group %>%
  group_by(dataset) %>%
  mutate(
    crowd_quartile = ntile(crowd_change_med, 4)
  ) %>%
  ungroup %>%
  group_by(dataset, crowd_quartile) %>%
  summarise(
    average_median_indv_change = mean(med_ind_change)
  )

quartile_dat_dataset %>% 
  ggplot(
    aes(x=crowd_quartile, y=average_median_indv_change, color=dataset)) +
  geom_point() +
  ggtitle("Average median individual change vs group outcome") +
  labs(x="Outcome of crowd", 
       y="Average median individual change") +
  geom_hline(yintercept=0, linetype="dashed", color="#333333") +
  nice_theme()


##### RAINCLOUD PLOTS #####

dat_group %>%
  group_by(dataset) %>%
  mutate(
    crowd_quartile = as.factor(ntile(crowd_change_med, 4))
  ) %>%
  ungroup %>%
  plot_raincloud(
    med_ind_change
    , groups = crowd_quartile
  )

quartile_dat %>% 
  plot_raincloud(
    average_median_indv_change
    , groups = crowd_quartile
  )


dat_group %>%
  group_by(dataset) %>%
  mutate(
    crowd_quartile = as.factor(ntile(crowd_change_med, 4))
  ) %>%
  ungroup %>%
  ggplot(
    aes(x = crowd_quartile, y = med_ind_change, fill = network)) +
  geom_violin(aes(color = network)) + #,position = position_nudge(x = .1, y = 0), adjust = 1.5, trim = TRUE, alpha = .5) #+
  # geom_point(aes(x = crowd_quartile, y = med_ind_change, colour = network),position = position_jitter(width = .05), size = 1, shape = 20) + 
  # geom_boxplot(aes(x = crowd_quartile, y = med_ind_change, fill = network),outlier.shape = NA, alpha = .5, width = .1, colour = "black") +
  # # scale_colour_brewer(palette = "Dark2") +
  # # scale_fill_brewer(palette = "Dark2") + 
  ylim(c(-.5, .5))
  # # ggtitle("Figure R10: Repeated Measures Factorial Rainclouds")

dat_group %>%
  group_by(dataset) %>%
  mutate(
    crowd_quartile = as.factor(ntile(crowd_change_med, 4))
  ) %>%
  ungroup %>%
  ggplot(
    aes(x = crowd_quartile, y = med_ind_change)) +
  geom_flat_violin(position = position_nudge(x = .1, y = 0), adjust = 1.5, trim = TRUE, alpha = .5) +
  geom_point(aes(x = crowd_quartile, y = med_ind_change), position = position_jitter(width = .05), size = 1, shape = 20) + 
  geom_boxplot(aes(x = crowd_quartile, y = med_ind_change),outlier.shape = NA, alpha = .5, width = .1, colour = "black") +
  # scale_colour_brewer(palette = "Dark2") +
  # scale_fill_brewer(palette = "Dark2") + 
  ylim(c(-.5, .5)) + 
    facet_grid(~network)


quartile_dat %>%  ggplot(aes(x = crowd_quartile, y = average_median_indv_change, fill = network)) +
  geom_flat_violin(aes(fill = network),position = position_nudge(x = .1, y = 0), adjust = 1.5, trim = FALSE, alpha = .5, colour = NA)+
  geom_point(aes(x = crowd_quartile, y = average_median_indv_change, colour = network),position = position_jitter(width = .05), size = 1, shape = 20)+
  geom_boxplot(aes(x = crowd_quartile, y = average_median_indv_change, fill = network),outlier.shape = NA, alpha = .5, width = .1, colour = "black")+
  scale_colour_brewer(palette = "Dark2")+
  scale_fill_brewer(palette = "Dark2")+
  ggtitle("Figure R11: Repeated Measures Factorial Rainclouds")



