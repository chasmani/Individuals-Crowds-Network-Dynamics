rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)

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
  group_by(task, trial, dataset, network) %>%
  mutate(
      mu1 = mean(pre_influence)
    , toward_truth = ifelse((pre_influence < mean(pre_influence) & mu1 <= truth) | (pre_influence > mu1 & mu1 >= truth), "Away","Toward")
    , s = var(pre_influence)
    # , outlierPre = tukey_out(pre_influence)
    # , outlierPost = tukey_out(post_influence)
  ) %>%
  ungroup %>%
  mutate(
    # , pre_log_err = log(abs(pre_influence-truth))
    , pre_sq_err_norm = ((pre_influence-truth)^2)/s
    # , pre_pct_err = abs(1-(pre_influence/truth))
    # , pre_log_pct_err = log(pre_pct_err + 0.00001)
    
    # , post_log_err = log(abs(post_influence-truth))
    , post_sq_err_norm = ((post_influence-truth)^2)/s
    # , post_pct_err = abs(1-(post_influence/truth))
    # , post_log_pct_err = log(post_pct_err + 0.00001)
    # ,ind_sd = sd
    , pre_err = pre_sq_err_norm
    , post_err = post_sq_err_norm
    
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
    , error_ntile = ntile(pre_err, 6)
    , calibration = tryCatch({cor.test(pre_err, confidence)$estimate},error=function(cond){NA})
  )  %>%
  group_by(task, dataset, network) %>%
  mutate(
    , task_calibration = tryCatch({cor.test(pre_err, confidence)$estimate},error=function(cond){NA})
  )
  # ungroup %>%
  # group_by(task, network) %>%
  # mutate(
  #   full_task_quartile = ntile(pre_err, 4)
  # ) %>%
  # ungroup %>%
  # group_by(network) %>%
  # mutate(
  #   full_error_quartile = ntile(pre_err, 4)
  # ) %>%
  # ungroup %>%
  # group_by(subject) %>%
  # mutate(
  #   skill_level = mean(error_ntile)
  # )




group_d = out_d %>%
  group_by(task, trial, dataset, network) %>%
  summarize(
      truth = unique(truth)
    # , totalN=unique(totalN)
    , N = n()
    , s = var(pre_influence)
    # , ind_sd = unique(ind_sd)
    # mean
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    
    #median
    # , med1 = median(pre_influence)
    # , med2 = median(post_influence)
    
    # crowd mean error
    , crowd_pre_err_mu = ((mu1-truth)^2)/s
    , crowd_post_err_mu =((mu2-truth)^2)/s
    
    # crowd median error
    # , crowd_pre_err_med = abs(med1-truth)
    # , crowd_post_err_med = abs(med2-truth)
    
    # change in crowd error
    , crowd_change_mu = crowd_post_err_mu - crowd_pre_err_mu
    # , crowd_change_med = crowd_post_err_med - crowd_pre_err_med
    , crowd_improvement = crowd_change_mu < 0
    , crowd_not_worse = crowd_change_mu <= 0
    
    # change in average individual error
    , mu_ind_change = mean(delta_err)
    , med_ind_change = median(delta_err)
    
    # , sd_err = sd(pre_log_err)
    
    # percentage improving per trial
    , pct_improve = sum(improve)/n()
    , pct_not_worse = sum(not_worse)/n()
    , pct_improve_revised = sum(revised[improve==1])/sum(revised)
    , pct_not_worse_revised = sum(revised[not_worse==1])/sum(revised)
    
    # , prop_toward = mean(toward_truth=="Toward")
    
    , mu_ind_improve = mu_ind_change<0
    
    , delta_err_math = crowd_change_mu - mu_ind_change
    
    , revised=sum(revised)
    
    , calibration=unique(calibration)
    , task_calibration=unique(task_calibration)
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



## warning message OK -- lowest levels automatically set to 1
myd=out_d %>%
  subset(!is.na(subject))%>%
  ungroup %>%
  # subset(task=="Columbus") %>% 
  # group_by(task)%>%
  mutate(
    err=pre_err
    ,err_quant=mycut(err)#, breaks=quantile(err, probs=seq(0,1,by=0.25)),
    # labels=1:4, include.lowest=T)%>%as.numeric
  )

mything = lapply(unique(myd$subject), function(s){
  # print(s)
  dx=myd[which(myd$subject==s),]%>%
    group_by(task)%>%summarize(err_quant=mean(err_quant))
  
  tasks=unique(dx$task)
  ds=data.frame(sapply(tasks,function(vt){
    sapply(unique(dx$task[dx$task!=vt]), function(t){
      subset(dx, task==t)$err_quant
    })%>%as.vector%>%as.numeric%>%mean
  }))
  
  
  ds$task=rownames(ds)
  colnames(ds)[1]="err_quant"
  ds$subject=s
  ds
}) %>%
  do.call(rbind, .)

comb_d=merge(out_d, mything, all=T)
