# rm(list=ls());gc()
library(ggplot2)
library(tidyverse,warn.conflicts = F, quietly = T)


if(!exists("mysetupvar")){
  source("1a_group_summaries.R")
  source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")
}



### by dataset
sum_d = processed_data %>%
  subset(!is.na(err_quant) & revised==1) %>%
  mutate(
    err_quant_round = round(err_quant)
  ) %>%
  mutate(
    #err_quant=round(err_quant*2)/2
    improve_revised=improve
  )%>%
  summarySE(measurevar="improve_revised", groupvars=c("dataset","err_quant_round"), na.rm=T, boot.trials=1000) %>%
  mutate(
    lower=improve_revised-se*1.96
    , lower=ifelse(lower<0, 0, lower)
    , upper=improve_revised+se*1.96
    , upper=ifelse(upper>1, 1, upper)
  )


sum_d %>%
  ggplot(aes(x=err_quant_round, y=improve_revised, group=dataset)) +
  geom_point() + geom_line() + 
  geom_hline(yintercept=0.5, linetype="dashed")+
  geom_errorbar(aes(ymin=lower, ymax=upper), width=0.075) +
  ylim(c(0,1)) + 
  facet_wrap(.~dataset,scales = "free") +
  nice_theme() +
  theme(
    strip.background = element_blank(),
    strip.text.x = element_blank()
  ) +
  scale_x_continuous( expand = c(0,0.6))

ggsave("../Figures/FigA3_raw.png", width=4.1, height=2.6)
