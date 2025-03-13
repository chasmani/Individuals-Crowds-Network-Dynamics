rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(reshape2)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)

source("0_data_prep.R")
source("0_helper_functions.R")


cols=c("pre_influence","post_influence","truth","task", "network", "trial", "dataset")


out_dat = rbind(
  lorenz_2011[, cols] %>% as.data.frame
  , becker_2017[, cols] %>% as.data.frame
  , gurcay_2015[, cols] %>% as.data.frame
  , becker_2019[, cols] %>% as.data.frame
  # , navajas_2018[, cols] %>% as.data.frame
  # , delphi_data[, cols] %>% as.data.frame
  # , discussion_data[, cols] %>% as.data.frame
  #, almaatouq_2020[, cols] %>% as.data.frame
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
  
  

dat_group = out_dat %>%
  group_by(task, trial, dataset, network) %>%
  summarize(
    truth = unique(truth)
    , N = n()
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
    , pct_improve = sum(improve)/n()
    , pct_not_worse = sum(not_worse)/n()
  ) %>%
  ungroup

dat_group_no_outliers = subset(out_dat, out_dat$isOutlier == FALSE) %>%
  group_by(task, trial, dataset, network) %>%
  summarize(
    truth = unique(truth)
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    , crowd_pre_err = abs(log(mu1/truth))
    , crowd_post_err = abs(log(mu2/truth))
    , mu_crowd_change = crowd_post_err - crowd_pre_err
    , mu_ind_change = mean(delta_err)
  ) %>%
  ungroup



outlier_dat = out_dat %>%
  subset(!(outlierPre | outlierPost))
