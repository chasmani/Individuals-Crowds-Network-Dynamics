rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(sdamr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)

source("Scripts/1a_group_summaries.R")


#TODO WORK IN PROGRESS - just looking at revised doesn't seem to be working, no difference between improve vs not worse

group_d %>%
  subset(network != "solo") %>%
  #subset(network != "solo" & !is.na(pct_improve_revised)) %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarise(
    mean_perc = mean(pct_not_worse)
  ) %>%
  ggplot(
    aes(crowd_improvement, mean_perc, color = network)) +
  geom_point() + 
  # geom_text(aes(label=network),hjust=-.2, vjust=0) +
  ggtitle("Inidividuals % Not Worse")+
  geom_hline(yintercept=0.5, linetype="dashed", color="#333333") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x="MEAN Crowd Error: Better or Worse", 
       y="MEAN % of indv \n not getting worse") + 
  facet_wrap(~dataset) +
  nice_theme()

summ = group_d %>%
  subset(network != "solo") %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarise(
    mean_perc = mean(pct_improve_revised)
  )

test = group_d %>%
  subset(network != "solo" & dataset == "becker 2019" & crowd_improvement == TRUE) %>%
  group_by(dataset, network, crowd_improvement)

test2 = out_d %>%
  group_by(task, trial, dataset, network) %>%
  mutate(
    mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    , crowd_pre_err = abs(log(mu1/truth))
    , crowd_post_err = abs(log(mu2/truth))
    , crowd_change_err = crowd_post_err - crowd_pre_err
  ) %>%
  ungroup

sum_test_2 = test2 %>%
  subset(revised == 1) %>%
  group_by(task, trial, dataset, network) %>%
  summarize(
    truth = unique(truth)
    , n = n()
    , crowd_change_err = unique(crowd_change_err)
    , crowd_outcome = crowd_change_err <= 0
    , mu_ind_change = mean(delta_err)
    , pct_improve = sum(improve)/n()
    , pct_not_worse = sum(not_worse)/n()
  )

