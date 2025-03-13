rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)
# DescTools gives us the sample variance estimar (biased estimator of sample variance), which is what we want
#install.packages("DescTools")
library(DescTools)

source("0a_data_preparation.R")
source("0b_helper_functions.R")

mycut = function(x) {
  breaks=quantile(x, probs=seq(0,1,by=0.25))
  out=sapply(x, function(z){
    max(which(breaks<z))
  })
  out[!is.finite(out)]=1
  out
}

mysetupvar="a12345"

cols=c(  "pre_influence","post_influence","truth","task"
       , "network", "trial", "dataset", "group_id"
       , "subject","confidence"
       )


out_d = rbind(
    lorenz_2011[, cols] %>% as.data.frame
  , becker_2017[, cols] %>% as.data.frame
  , gurcay_2015[, cols] %>% as.data.frame
  , becker_2019[, cols] %>% as.data.frame
  , silver_2021[, cols] %>% as.data.frame
  , becker_2020[, cols] %>% as.data.frame
) %>% 
  subset(!is.na(pre_influence) & !is.na(post_influence)) %>%
  mutate(
      pre_indy_error = (pre_influence - truth)^2
    , post_indy_error = (post_influence - truth)^2
    , delta_indy_error = post_indy_error - pre_indy_error
    , delta_indy_opinion = (post_influence - pre_influence)/(pre_influence - truth)
    , improved = (post_indy_error < pre_indy_error)
      ) %>%
  group_by(task, trial, dataset, network) %>%
  mutate(
      pre_mu = mean(pre_influence)
    , post_mu = mean(post_influence)
    , pre_s2 = VarN(pre_influence)
    , post_s2 = VarN(post_influence)
    , pre_crowd_error = (pre_mu - truth)^2
    , post_crowd_error = (post_mu - truth)^2
    , standardised_delta_crowd_error = (post_crowd_error - pre_crowd_error)/pre_s2
    , delta_crowd_opinion = (post_mu - pre_mu) / (pre_mu - truth)
    , standardised_mean_delta_indy_error = mean(delta_indy_error)/pre_s2
    , standardised_delta_s2 = (post_s2 - pre_s2)/pre_s2
    , relative_pre_accuracy = (pre_influence - truth)^2/pre_s2
    # , outlierPre = tukey_out(pre_influence)
    # , outlierPost = tukey_out(post_influence)
  ) %>%
  ungroup %>%
  subset(is.finite(pre_crowd_error) & is.finite(post_crowd_error))

participant_avg_accuracy <- out_d %>%
  group_by(subject) %>%
  summarize(mean_accuracy = mean(relative_pre_accuracy, na.rm=TRUE))

participant_accuracy_deciles <-  participant_avg_accuracy %>%
  mutate(accuracy_decile = ntile(mean_accuracy, 10))

data_with_deciles <- out_d %>%
  left_join(participant_accuracy_deciles, by = "subject")

d_clean <- data_with_deciles %>%
  subset(is.finite(delta_indy_opinion)) %>%
  filter(abs(delta_indy_opinion) <= 10) %>%
  filter(delta_indy_error != 0)

decile_summary <- d_clean %>%
  group_by(accuracy_decile) %>%
  summarize(
    mean_delta_error = mean(improved),
    se_delta_error = sd(improved) / sqrt(n())
  )

ggplot(decile_summary, aes(x = factor(accuracy_decile), y = mean_delta_error)) +
  geom_point(size = 3, color = "black") +
  geom_errorbar(aes(ymin = mean_delta_error - 1.98*se_delta_error, 
                    ymax = mean_delta_error + 1.98*se_delta_error),
                width = 0.2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "black") +
  labs(x = "Accuracy Decile", y = "P(Improved)",) +
  theme_minimal() + 
  theme(
    panel.grid.major.y = element_blank(),  # Remove major horizontal gridlines
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_blank(),  # Remove major horizontal gridlines
    panel.grid.minor.x = element_blank())
  
ggsave("../Figures/prob_improve_by_accuracy_decile.png", dpi=600, bg="#ffffff")
