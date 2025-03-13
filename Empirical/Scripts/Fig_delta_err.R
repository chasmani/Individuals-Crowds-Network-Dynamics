# rm(list=ls());gc()
library(ggplot2)
library(tidyverse,warn.conflicts = F, quietly = T)


if(!exists("mysetupvar")){
  source("1a_group_summaries.R")
  source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")
}



# thr=50

# math_summary = group_d %>%
#   mutate(
#     crowd_improvement = ifelse(crowd_improvement, "Improve","Worse")
#   )%>%
#   subset(
#     delta_err_math>=(0)
#   ) %>%
#   subset(
#      # crowd_change_mu<thr & crowd_change_mu>-1*thr &
#       # mu_ind_change<thr & mu_ind_change>-1*thr
#   ) %>%
#   group_by(dataset
#            , crowd_improvement
#            ) %>%
#   summarize(
#       mean_delt = mean(delta_err_math)
#     , med_delt = median(delta_err_math)
#     , median_group = median(crowd_change_mu)
#     , median_ind = median(mu_ind_change)
#     , mean_group = mean(crowd_change_mu)
#     , mean_ind = mean(mu_ind_change)
#     , prob_delt_positive = mean(delta_err_math>0)
#   )

# math_summary %>%
#   select(dataset
#          , crowd_improvement
#          , mean_group, mean_ind) %>%
#   pivot_longer(!c(dataset
#                   , crowd_improvement
#                   )) %>%
#   mutate(
#     group = paste0(dataset, crowd_improvement)
#     , name=fct_recode(name, 
#                       "Group Change"="mean_group"
#                       , "Individ. Change"="mean_ind"
#                       )
#     # , crowd_improvement = fct_recode(crowd_improvement,
#     #                                  "Crowd Improve"="Improve"
#     #                                  ,"Crowd Worse"="Worse"
#     #                                  )
#   )%>%
#   ggplot(aes(x=value, y=dataset
#              , color=crowd_improvement
#              , group=group, shape=name)) +
#   geom_point(size=2) + geom_line() +
#   geom_vline(xintercept = 0) +
#   nice_theme() +
#   theme(axis.title.x=element_text(size=8,face="plain"))+
#   labs(y="", x="Change in Normalized Error", shape="", color="")
#   
# ggsave("../Figures/delta_err.png", width=5, height=3)


### calculate the slope & intercept of regression
### for a range of possible data exclusion thresholds

myseq=c(
  1:10
  , seq(20,100,by=10)
  , seq(150,1000, by=50)
   # , seq(1000, 10000, by=250)
)
thresh_analysis = sapply(myseq,
       FUN=function(thr){
         mod=group_d %>%
           subset(
             abs(crowd_change_mu)<thr &
               abs(mu_ind_change)<thr
           )%>%
           lm(mu_ind_change ~ crowd_change_mu, .) %>%
           summary
         
         incl=with(group_d, sum(  crowd_change_mu<thr & crowd_change_mu>-1*thr &
                               mu_ind_change<thr & mu_ind_change>-1*thr))
         
         
         data.frame(
             thr=thr
           , intercept=mod$coefficients["(Intercept)","Estimate"]
           , b=mod$coefficients["crowd_change_mu","Estimate"]
           , incl=incl/2320
         )
       }
) %>%
  t %>%
  as.data.frame %>%unnest

thresh_analysis %>%
  ggplot(aes(x=thr, y=intercept))+geom_line()+
  scale_x_log10(
    breaks = c(0,1,10,100,1000)#scales::trans_breaks("log10", function(x) 10^x),
    ,labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) + 
  geom_line(aes(y=b), color="red")+
  geom_line(aes(y=incl), color="blue")+
  ylim(c(-1.2,1.2)) + 
  nice_theme() +
  geom_hline(yintercept=0, linetype="dashed") +
  scale_y_continuous( expand = c(0,0.1), )

ggsave("../Figures/appendix_delta_fig.png", width=2, height=1.8)

#### manually inspect the weird datapoints

thr=1000
weird=group_d[which(
  group_d$crowd_change_mu>thr | group_d$crowd_change_mu<(-1*thr)
  | group_d$mu_ind_change>thr | group_d$mu_ind_change<(-1*thr)
  ),]

View(weird)

myd=subset(group_d, trial=="Madagascar1131d")





### OVERALL RESULTS FOR d>0
mean(group_d$delta_err_math>=0)

group_d %>%
  subset(
    delta_err_math>0
  )%>%
  lm(mu_ind_change ~ crowd_change_mu, .) %>%
  summary

## conf interval on intercept
-0.6388848+0.004706*1.960
-0.6388848
-0.6388848-0.004706*1.960

## conf interval on slope
0.9981+0.0009545*1.960
0.9981
0.9981-0.0009545*1.960

data.frame(
  thr=thr
  , intercept=mod$coefficients["(Intercept)","Estimate"]
  , b=mod$coefficients["crowd_change_mu","Estimate"]
  , incl=incl/2320
)
  


### regression figure
group_d %>%
  # group_by(dataset, task) %>%
  # summarize(
  #   mu_ind_change=mean(mu_ind_change)
  #   ,crowd_change_mu=mean(crowd_change_mu)
  # )%>%
  ggplot(aes(x=crowd_change_mu, y=mu_ind_change#, color=dataset
             ))+
  geom_point(size=0.01, shape=20) +
  xlim(c(-10,10)) +
  ylim(c(-10,10)) +
  geom_abline(intercept=-0, slope=1, linetype="dashed") +
  geom_abline(intercept=-1, slope=1, linetype="dashed") +
  grafify::scale_color_grafify(palette="okabe_ito")+
  nice_theme()


ggsave("../Figures/slope_figure_most.png", width=2.5, height=2.2, dpi=1000)




### regression figure
group_d %>%
  # group_by(dataset, task) %>%
  # summarize(
  #   mu_ind_change=mean(mu_ind_change)
  #   ,crowd_change_mu=mean(crowd_change_mu)
  # )%>%
  ggplot(aes(x=crowd_change_mu, y=mu_ind_change#, color=dataset
  ))+
  geom_point(size=0.01, shape=20) +
  xlim(c(-2,2)) +
  ylim(c(-2,2)) +
  geom_abline(intercept=-0, slope=1, linetype="dashed") +
  geom_abline(intercept=-1, slope=1, linetype="dashed") +
  grafify::scale_color_grafify(palette="okabe_ito")+
  nice_theme()


ggsave("../Figures/slope_figure_close.png", width=2.2, height=2.2)

mean(abs(group_d$crowd_change_mu)<=2)
mean(abs(group_d$crowd_change_mu)<=10)
