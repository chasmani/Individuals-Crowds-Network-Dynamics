rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)

source("Scripts/0a_data_preparation.R")
source("Scripts/0_helper_functions.R")


cols=c("pre_influence","post_influence","truth","task", "network", "trial", "dataset", "group_id")


out_d = rbind(
  lorenz_2011[, cols] %>% as.data.frame
  , becker_2017[, cols] %>% as.data.frame
  , gurcay_2015[, cols] %>% as.data.frame
  , becker_2019[, cols] %>% as.data.frame
) %>% 
  subset(!is.na(pre_influence) & !is.na(post_influence)) %>%
  group_by(task, trial, dataset, network) %>%
  mutate(
    outlierPre = tukey_out(pre_influence)
    , outlierPost = tukey_out(post_influence)
  ) %>%
  ungroup %>%
  mutate(
    pre_err = abs(log(pre_influence/truth))
    , post_err = abs(log(post_influence/truth))
    , delta_err = post_err - pre_err
    , improve = ifelse(delta_err < 0, 1, 0)
    , not_worse = ifelse(delta_err > 0, 0, 1)
    , isOutlier = tukey_out(delta_err)
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
  ungroup



group_d = out_d %>%
  group_by(task, trial, dataset, network) %>%
  summarize(
    truth = unique(truth)
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
    , crowd_improvement = crowd_change_mu <= 0
    
    # change in average individual error
    , mu_ind_change = mean(delta_err)
    , med_ind_change = median(delta_err)
    
    # percentage improving per trial
    , pct_improve = sum(improve)/n()
    , pct_not_worse = sum(not_worse)/n()
    , pct_improve_revised = sum(revised[improve==1])/sum(revised)
    , pct_not_worse_revised = sum(revised[not_worse==1])/sum(revised)
  ) %>%
  ungroup


## TODO testing of calculating revised pct - works here but not with actual data
# test = data.frame(
#   belief = rnorm(40, 20, 5)
#   , belief2 = rnorm(40, 20, 5)
# ) %>%
#   mutate(
#   improve = ifelse(abs(belief2 - belief) > 3, 1, 0)
#   , not_worse = ifelse(abs(belief2 - belief) > 5, 0, 1)
#   , revised = rep(c(0,1), 20)
# )
# 
# 
# summ = test %>%
#   summarise(
#     pct_improve = sum(improve)/n()
#     , pct_not_worse = sum(not_worse)/n()
#     , pct_improve_revised = sum(revised[improve==1])/sum(revised)
#     , pct_not_worse_revised = sum(revised[not_worse==1])/sum(revised)
#   )
# 
# summ2 = test %>%
#   summarise(
#     pct_improve = sum(improve)/n()
#     , pct_not_worse = sum(not_worse)/n()
#     , pct_improve_revised = sum(improve[revised==1])/sum(revised)
#     , pct_not_worse_revised = sum(not_worse[revised==1])/sum(revised)
#   )


