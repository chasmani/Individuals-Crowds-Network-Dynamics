rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(sdamr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)
library(afex)
library(emmeans)

source("1a_group_summaries.R")

# library(lme4)



hlm_decent_improve = group_d %>% 
  subset(crowd_improvement == T) %>%
  subset(network=="decentralized") %>%
  lmer(formula = mu_ind_change ~ 1 + (1|dataset),
                           data    = .)


lm_decent_improve = group_d %>% 
  subset(crowd_improvement == T) %>%
  subset(network=="decentralized") %>%
  lm(formula = mu_ind_change ~ 1,
       data    = .)


lm_cent_improve = group_d %>% 
  subset(crowd_improvement == T) %>%
  subset(network=="centralized") %>%
  lm(formula = mu_ind_change ~ 1,
       data    = .)

hlm_disc_improve = group_d %>% 
  subset(crowd_improvement == T) %>%
  subset(network=="discussion") %>%
  lmer(formula = mu_ind_change ~ 1 + (1|dataset),
       data    = .)

hlm_solo_improve = group_d %>% 
  subset(crowd_improvement == T) %>%
  subset(network=="solo") %>%
  lmer(formula = mu_ind_change ~ 1 + (1|dataset),
       data    = .)




hlm_decent_worse = group_d %>% 
  subset(crowd_improvement == F) %>%
  subset(network=="decentralized") %>%
  lmer(formula = mu_ind_change ~ 1 + (1|dataset),
       data    = .)


lm_decent_worse = group_d %>% 
  subset(crowd_improvement == F) %>%
  subset(network=="decentralized") %>%
  lm(formula = mu_ind_change ~ 1,
     data    = .)


lm_cent_worse = group_d %>% 
  subset(crowd_improvement == F) %>%
  subset(network=="centralized") %>%
  lm(formula = mu_ind_change ~ 1,
     data    = .)

hlm_disc_worse = group_d %>% 
  subset(crowd_improvement == F) %>%
  subset(network=="discussion") %>%
  lmer(formula = mu_ind_change ~ 1 + (1|dataset),
       data    = .)

hlm_solo_worse = group_d %>% 
  subset(crowd_improvement == F) %>%
  subset(network=="solo") %>%
  lmer(formula = mu_ind_change ~ 1 + (1|dataset),
       data    = .)


summary(hlm_decent_improve)
summary(lm_decent_improve)

summary(lm_cent_improve)

summary(hlm_disc_improve)

summary(hlm_solo_improve)


summary(hlm_decent_worse)
summary(lm_decent_worse)

summary(lm_cent_worse)

summary(hlm_disc_worse)

aov(hlm_solo_worse) %>% summary
