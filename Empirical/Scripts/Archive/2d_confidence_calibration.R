### set working directory to Empirical

rm(list=ls());gc()
library(ggplot2)
library(tidyverse,warn.conflicts = F, quietly = T)

source("Scripts/1a_group_summaries.R")
source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")



cols = cols=c("pre_influence"
              ,"post_influence"
              ,"truth"
              ,"task"
              , "network"
              , "trial"
              , "dataset"
              , "group_id"
              , "confidence")


out_d = rbind(
    lorenz_2011[, cols] %>% as.data.frame
  , silver_2021[, cols] %>% as.data.frame
  , gurcay_2015[, cols] %>% as.data.frame
) %>% 
  subset(!is.na(pre_influence) & !is.na(post_influence)) %>%
  group_by(task, trial, dataset, network) %>%
  #mutate(
  #    outlierPre = tukey_out(pre_influence)
  #  , outlierPost = tukey_out(post_influence)
  #) %>%
  ungroup %>%
  mutate(
    pre_err = abs(log(pre_influence/truth))
    , post_err = abs(log(post_influence/truth))
    , delta_err = post_err - pre_err
    , improve = ifelse(delta_err < 0, 1, 0)
    , not_worse = ifelse(delta_err > 0, 0, 1)
    #, isOutlier = tukey_out(delta_err)
    , condition = paste0(dataset, network)
    , revised = ifelse(pre_influence == post_influence, 0, 1)
  ) %>% 
  subset(is.finite(pre_err) & is.finite(post_err)) %>%
  group_by(task, trial, dataset, network) %>%
  mutate(
    error_quartile = ntile(pre_err, 4)
  ) %>%
  ungroup %>%
  group_by(task, network) %>%
  mutate(
    full_task_quartile = ntile(pre_err, 4)
  ) %>%
  ungroup %>%
  group_by(network) %>%
  mutate(
    full_error_quartile = ntile(pre_err, 4)
  ) %>%
  ungroup %>%
  subset(network!="solo")



group_d = out_d %>%
  group_by(task, trial, dataset, network) %>%
  summarize(
      calibration = cor(confidence, pre_err)*(-1)
    , cal.round = round(calibration,1)
    
    
    , truth = unique(truth)
    , N = n()
    
    # mean
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    
    #median
    , med1 = median(pre_influence)
    , med2 = median(post_influence)
    
    # crowd mean error
    , crowd_pre_err_mu = abs(log(mu1/truth))
    , crowd_post_err_mu = abs(log(mu2/truth))
    
    # crowd median error
    , crowd_pre_err_med = abs(log(med1/truth))
    , crowd_post_err_med = abs(log(med2/truth))
    
    # change in crowd error
    , crowd_change_mu = crowd_post_err_mu - crowd_pre_err_mu
    , crowd_change_med = crowd_post_err_med - crowd_pre_err_med
    , crowd_improvement = (crowd_change_mu <= 0)*1
    
    # change in average individual error
    , mu_ind_change = mean(delta_err)
    , med_ind_change = median(delta_err)
    
    # percentage improving per trial
    , pct_improve = sum(improve)/n()
    , pct_not_worse = sum(not_worse)/n()
    , pct_improve_revised = sum(revised[improve==1])/sum(revised)
    , pct_not_worse_revised = sum(revised[not_worse==1])/sum(revised)
  )

beckertheme =   theme(panel.background=element_rect(fill="white", color="black", size=1.1), 
                      axis.text=element_text(size=rel(1), color="black"), 
                      strip.text=element_text(size=rel(1.1)), 
                      legend.text=element_text(size=rel(1.1)), strip.background=element_blank(),
                      title=element_text(size=rel(1.1)),
                      panel.grid=element_blank(),
                      plot.title=element_text(hjust=0.5),
                      aspect.ratio = 1)


group_d %>%
  #subset(change_err<100000) %>%
  ggplot(aes(x=cal.round, y=mu_ind_change)) +
  facet_wrap(.~dataset) +
  stat_summary(fun="mean", geom="point") +
  geom_hline(yintercept=0, linetype="dashed") +
  labs(x="Calibration", y="Change in Avg. Individual Error") +
  beckertheme
ggsave("Figures/CALIBRATION_ind_error_by.png")



group_d %>%
  #subset(change_err<100000) %>%
  ggplot(aes(x=cal.round, y=pct_not_worse)) +
  facet_wrap(.~dataset) +
  stat_summary(fun="mean", geom="point") +
  geom_hline(yintercept=0.5, linetype="dashed") +
  labs(x="Calibration", y="% of Individuals Not Worse") +
  ylim(c(0,1)) +
  beckertheme
ggsave("Figures/CALIBRATION_pct_not_worse.png")


group_d %>%
  #subset(change_err<100000) %>%
  ggplot(aes(x=cal.round, y=crowd_change_mu)) +
  facet_wrap(.~dataset) +
  stat_summary(fun="mean", geom="point") +
  geom_hline(yintercept=0, linetype="dashed") +
  labs(x="Calibration", y="Change in (Group) Error of Mean") +
  beckertheme
ggsave("Figures/CALIBRATION_change_group_error.png")


group_d %>%
  #subset(change_err<100000) %>%
  ggplot(aes(x=cal.round, y=crowd_improvement)) +
  facet_wrap(.~dataset) +
  stat_summary(fun="mean", geom="point") +
  geom_hline(yintercept=0.5, linetype="dashed") +
  labs(x="Calibration", y="% Groups Not Worse") +
  beckertheme +
  ylim(c(0,1))
ggsave("Figures/CALIBRATION_change_group_error_PCT.png")
