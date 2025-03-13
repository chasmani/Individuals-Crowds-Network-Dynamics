rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(reshape2)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)

data_path = "data/"
data_file = "lorenz_2011.csv"

dat <- read.csv(paste0(data_path, data_file)) %>%
  mutate(
    err1 = abs(log(E1/Truth))
    , err5 = abs(log(E5/Truth))
    , delta = err5 - err1
    , network= fct_recode(Information_Condition, "Social" = "full", "Control" = "no", "Social"="aggregated")
    , improvement = ifelse(delta > 0, 0, 1)
    , trial= paste0(Information_Condition, Session_Date)
    , task = Question
  )

# dat <- read.csv(paste0(data_path, data_file)) %>%
#   mutate(
#     err_pre = E1 - Truth
#     ,norm_err_pre = abs(err_pre/Truth)
#     ,log_err_pre = abs(log(E1/Truth))
#     ,err_post = E5 - Truth
#     ,norm_err_post = abs(err_post/Truth)
#     ,log_err_post = abs(log(E5/Truth))
#     , norm_delta = norm_err_post - norm_err_pre
#     , log_delta = log_err_post - log_err_pre
#     , network= fct_recode(Information_Condition, "Social" = "full", "Control" = "no", "Social"="aggregated") 
#     , improvement = ifelse(norm_delta > 0, 0, 1)
#     , trial= paste0(Information_Condition, Session_Date)
#     , task = Question
#   )

head(dat)

tukey_out <- function(x, k = 2, na.rm = TRUE) {
  quar <- quantile(x, probs = c(0.25, 0.75), na.rm = na.rm)
  iqr <- diff(quar)
  
  !((quar[1] - k * iqr <= x) & (x <= quar[2] + k * iqr))
}


dat <- dat %>% mutate(isOutlierRating = tukey_out(delta))

table(dat$isOutlierRating)
dat$isOutlierRating
sum(dat$isOutlierRating,  na.rm = T)

dat = subset(dat, dat$isOutlierRating == FALSE)
sum(dat$isOutlierRating,  na.rm = T)

dat = dat %>%
  group_by(Question) %>%
    mutate(
      error_quartile = ntile(err1, 4)
    ) %>%
  ungroup()



dat %>%
  
ggplot(
              aes(x=error_quartile, y=delta)) + stat_summary(fun.y="mean", geom="bar") +
  facet_grid(.~network)

dat

dat.plot <- dat %>% 
  group_by(error_quartile, network) %>% 
  summarize(improvement_likelihood = sum(improvement)/n())

dat.plot %>%
  ggplot(
    aes(x=error_quartile, y=improvement_likelihood, fill=network, group=network)) + geom_bar(stat="identity", position = 'dodge')
   



dat.group = dat %>%
  ungroup() %>%
  group_by(task, trial, network) %>%
  summarize(
    
    Truth=unique(Truth)
    , mu1 = mean(E1)
    , mu2 = mean(E5)
    , crowd_pre_err = abs(log(mu1/Truth))
    , crowd_post_err = abs(log(mu2/Truth))
    , mu_crowd_change = crowd_post_err - crowd_pre_err
    , mu_ind_change = mean(delta)
  )


head(dat.group)

dat.group$change_err_mu

#write_csv(dat.group, "data/lorenz_groupsumm.csv")           


dat.group %>%
  group_by(trial) %>%
  ggplot(
    aes(x=mu_ind_change, y=mu_crowd_change)) + stat_summary(fun.data=mean_cl_normal) + 
  geom_smooth(method='lm', formula= y~x) + 
  facet_grid(~network)
  


subset(dat.group, dat.group$network == "Social") %>%
  group_by(trial) %>%
  ggplot(
    aes(x=mu_ind_change, y=mu_crowd_change)) + stat_summary(fun.data=mean_cl_normal) + 
  geom_smooth(method='lm', formula= y~x)

subset(dat.group, dat.group$network == "Social") %>%
  group_by(trial) %>%
  ggplot(
    aes(x=mu_crowd_change, y=mu_ind_change)) + stat_summary(fun.data=mean_cl_normal) + 
  geom_smooth(method='lm', formula= y~x)
  

dat.group %>% 
  group_by(trial) %>%
  summarize(
    N = n()
  )

subset(dat.group, dat.group$network == "Social") %>%
  group_by(trial) %>%
  summarize(
    N = n()
  )

summary(dat)
summary(dat.group)


           
       