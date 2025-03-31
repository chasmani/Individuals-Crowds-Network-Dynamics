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



cols=c(  "pre_influence","post_influence","truth","task"
       , "network", "trial", "dataset", "group_id"
       , "subject","confidence"
       )


partially_processed_data = rbind(
    lorenz_2011[, cols] %>% as.data.frame
  , becker_2017[, cols] %>% as.data.frame
  , gurcay_2015[, cols] %>% as.data.frame
  , becker_2019[, cols] %>% as.data.frame
  , silver_2021[, cols] %>% as.data.frame
  , becker_2020[, cols] %>% as.data.frame
) %>% 
  
  ### we only examine people who give both estimates
  subset(!is.na(pre_influence) & !is.na(post_influence)) %>%
  group_by(task, trial, dataset, network) %>%
  
  ## calculate trial-level means for measuring deviance
  mutate(
      mu1 = mean(pre_influence)
  ) %>%
  ungroup %>%
  mutate(
    # individual pre and post squared error and 'herding' distance
    , pre_err = ((pre_influence-truth)^2)
    , post_err = ((post_influence-truth)^2)
    
    # initial deviance
    , pre_deviance = (pre_influence-mu1)^2
    
    # individual change in error
    , ind_delta_err = post_err - pre_err
    , improve = ifelse(ind_delta_err < 0, 1, 0)
    , not_worse = ifelse(ind_delta_err > 0, 0, 1)
    , revised = ifelse(pre_influence == post_influence, 0, 1)
    
    # trial details
    , condition = paste0(dataset, network)
  ) %>% 
  subset(is.finite(pre_err) & is.finite(post_err)) %>%
  group_by(task, trial, dataset, network) %>%
  mutate(
      error_quartile = ntile(pre_err, 4)
    , error_ntile = ntile(pre_err, 6)
    # , conf_calibration = tryCatch({cor.test(pre_err, confidence)$estimate},error=function(cond){NA})
    # , conf_herding = tryCatch({cor.test(pre_dist_from_avg, confidence)$estimate},error=function(cond){NA})
  )  #%>%
  # group_by(task, dataset, network) %>%
  # mutate(
    # , task_conf_calibration = tryCatch({cor.test(pre_err, confidence)$estimate},error=function(cond){NA})
    # , task_conf_herding = tryCatch({cor.test(pre_dist_from_avg, confidence)$estimate},error=function(cond){NA})
  # )


group_data = partially_processed_data %>%
  group_by(task, trial, dataset, network) %>%
  summarize(
      truth = unique(truth)
    , N = n()
    , s_pre = sd(pre_influence)
    , s_post = sd(post_influence)

    # crowd mean
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)

    # crowd mean error
    , crowd_pre_err = ((mu1-truth)^2)
    , crowd_post_err =((mu2-truth)^2)
    
    # change in crowd error
    , crowd_change = crowd_post_err - crowd_pre_err
    , crowd_change_normalized = crowd_change / ((s_pre^2))
    , crowd_improvement = crowd_change < 0
    , crowd_not_worse = crowd_change <= 0
    
    # change in average individual error
    , ind_change = mean(ind_delta_err)
    , ind_change_normalized = ind_change / ((s_pre^2))
    
    # change in variance/diversity
    , s_squared_change = (s_post^2) - (s_pre^2)
    
    # percentage improving per trial
    , pct_improve = sum(improve)/n()
    , pct_not_worse = sum(not_worse)/n()
    , pct_improve_revised = sum(revised[improve==1])/sum(revised)
    , pct_not_worse_revised = sum(revised[not_worse==1])/sum(revised)
    
    # , prop_toward = mean(toward_truth=="Toward")
    
    , delta_err_math = ind_change_normalized - crowd_change_normalized
    
    , revised=sum(revised)
    
    # , conf_calibration=unique(conf_calibration)
    # , task_conf_calibration=unique(task_conf_calibration)
    
    # , conf_herding = unique(conf_herding)
    # , task_conf_herding = unique(task_conf_herding)
  ) %>%
  ungroup



## calculate dataframe that holds error quantile for individuals
## warning message is OK -- lowest levels automatically set to 1
quantile_table=partially_processed_data %>%
  subset(!is.na(subject))%>%
  ungroup %>%
  group_by(task)%>%
  mutate(
     err=pre_err
    ,err_quant=mycut(err)
  )


### for each task, calculate the error quantile on OTHER tasks
### so we can assign someone a "skill"-like *socially relative* error metric
### that is not susceptible to Regression-To-The-Mean

skill_calc = lapply(unique(quantile_table)$subject, function(s){
  
  
  ### obtain table of error quantile for each independent task
  dx=quantile_table[which(quantile_table$subject==s),]%>%
    group_by(task)%>%summarize(err_quant=unique(err_quant))
  
  ### get list of tasks for indexing
  tasks=unique(dx$task)
  
  ### for each task, obtain average of error quantiles
  ### for all OTHER tasks
  ds=data.frame(sapply(tasks,function(vt){
    
    
    ### for each tasks, obtain error quantiles of other tasks
    sapply(unique(dx$task[dx$task!=vt]), function(t){
      subset(dx, task==t)$err_quant
      
      ### then calculate mean for output
    })%>%unlist%>%as.vector%>%as.numeric%>%mean
  }))
  
  
  ds$task=rownames(ds)
  colnames(ds)[1]="err_quant"
  ds$subject=s
  ds
}) %>%
  do.call(rbind, .)

processed_data=merge(partially_processed_data, skill_calc, all=T)

mysetupvar="a12345"