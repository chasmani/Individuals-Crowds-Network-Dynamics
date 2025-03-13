rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)

source("0a_data_preparation.R")
source("0b_helper_functions.R")


cols=c(  "pre_influence","post_influence","truth","task"
       , "network", "trial", "dataset", "group_id"
       , "subject"
       )


get_all_diff = function(x) {
  sapply(x, function(i){
    mean(x-i)
  })
}

out_d = rbind(
    lorenz_2011[, cols] %>% as.data.frame
  , becker_2017[, cols] %>% as.data.frame
  , gurcay_2015[, cols] %>% as.data.frame
  , becker_2019[, cols] %>% as.data.frame
  , silver_2021[, cols] %>% as.data.frame
  , becker_2020[, cols] %>% as.data.frame
) %>% 
  subset(!is.na(pre_influence) & !is.na(post_influence)) %>%
  group_by(task, trial, dataset, network) %>%
  mutate(
      mu1 = mean(pre_influence)
    , toward_truth = ifelse((pre_influence < mean(pre_influence) & mu1 <= truth) | (pre_influence > mu1 & mu1 >= truth), "Away","Toward")
    # , outlierPre = tukey_out(pre_influence)
    # , outlierPost = tukey_out(post_influence)
  ) %>%
  ungroup %>%
  mutate(
      pre_err = log(abs(pre_influence/truth))
    , post_err = log(abs(post_influence/truth))
    , pre_err_abs = log(abs(pre_influence/truth))
    , post_err_abs = log(abs(post_influence/truth))
    , pre_err_pct = (abs(pre_influence/truth))
    , post_err_pct = (abs(post_influence/truth))
    , delta_err = post_err - pre_err
    , improve = ifelse(delta_err < 0, 1, 0)
    , not_worse = ifelse(delta_err > 0, 0, 1)
    # , isOutlier = tukey_out(delta_err)
    , condition = paste0(dataset, network)
    , revised = ifelse(pre_influence == post_influence, 0, 1)
  ) %>% 
  subset(is.finite(pre_err) & is.finite(post_err)) %>%
  group_by(task, trial, dataset, network) %>%
  mutate(
      error_quartile = ntile(pre_err, 4)
    , error_quartile_abs = ntile(pre_err_abs, 4)
    , error_ntile = ntile(pre_err, 6)
    , delta_err_rand = get_all_diff(pre_err)
  ) 



out_d %>%
  group_by(error_quartile) %>%
  summarize(
    baseline = mean(delta_err_rand)
    , delta = mean(delta_err)
  )

out_d$delta_err_rand
