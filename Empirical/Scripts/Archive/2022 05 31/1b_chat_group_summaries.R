rm(list=ls());gc()
require(DescTools)
require(tidyverse)

source("Scripts/0b_chat_data_preparation.R")

cols=c("dataset", "task", "trial", "pre_influence","post_influence","truth",
       "is_central","count_chat","count_words", "soc_info")

out_d = rbind(
    gurc_d[, cols] %>% as.data.frame
  , discussion_d[, cols] %>% as.data.frame
  , becker17_d[, cols] %>% as.data.frame
  ) %>%
  subset(!is.na(pre_influence) & !is.na(post_influence)) %>%
  mutate(
    alpha = (pre_influence - post_influence)/(pre_influence-soc_info)
    , stubborn_cent = 1-alpha
    , pre_err = abs(log(pre_influence/truth))
    , post_err = abs(log(post_influence/truth))
    , delta_err = post_err - pre_err
    , improve = ifelse(delta_err<0, 1, 0)
    , not_worse = ifelse(delta_err > 0, 0, 1)
  ) %>%
  group_by(task, trial, dataset) %>%
  mutate(
    mu1 = mean(pre_influence)
    , toward_truth = ifelse((pre_influence < mean(pre_influence) & mu1 <= truth) | (pre_influence > mu1 & mu1 >= truth), "Away","Toward")
  ) %>%
  ungroup


group_d = out_d %>%
  group_by(task, trial, dataset) %>%
  summarize(
    truth=unique(truth)
    ## mean
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    
    ## error of mean
    , crowd_pre_err = abs(log(mu1/truth))
    , crowd_post_err = abs(log(mu2/truth))
    , mu_crowd_change = crowd_post_err - crowd_pre_err
    , mu_ind_change = mean(delta_err)
    
    ## centralization
    , gini_alpha = Gini(stubborn_cent)
    , gini_alpha = ifelse(is.na(gini_alpha), 0, gini_alpha)
    
    , gini_talkativeness = Gini(count_chat)
    , gini_talkativeness_present_only = Gini(count_chat[count_chat>0])
    , gini_words = Gini(count_words)
    , mean_talkativeness = mean(count_chat)
    , mean_talkativeness_present_only = mean(count_chat[count_chat>0])
    , mean_words = mean(count_words)
    , total_talkativeness=sum(count_chat)
    , total_words = sum(count_words)
    , count_in_convo = sum(count_words!=0)
    
    # old version used ifelse(dataset == "becker 2017") - this included a datapoint for each row in ouput_dat instead of summary acrross the group, similiar to not using unique(truth)
    , central_twd_truth = if(any(`dataset` ==  "becker 2017")) toward_truth[is_central == TRUE]=="Toward"
    else toward_truth[!is.na(toward_truth)][which.max(count_chat[!is.na(toward_truth)])]=="Toward"
    
    # group improvement
    , pct_improve = sum(improve)/n()
    , pct_not_worse = sum(not_worse)/n()
    , crowd_improve = ifelse(mu_crowd_change < 0, 1, 0)
    , crowd_not_worse = ifelse(mu_crowd_change > 0, 0, 1)
    
  ) %>%
  subset(is.finite(mu_ind_change))

    
