# rm(list=ls());gc()
library(ggplot2)
library(tidyverse,warn.conflicts = F, quietly = T)


if(!exists("mysetupvar")){
  source("1a_group_summaries.R")
  source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")
}



sum_d = comb_d %>%
  subset(!is.na(err_quant) & revised==1) %>%
  mutate(
    err_quant=round(err_quant)
    , improve_revised=improve
  )%>%
  summarySE(measurevar="improve_revised", groupvars=c("dataset","err_quant"), na.rm=T, boot.trials=1000) %>%
  mutate(
      lower=improve_revised-se*1.96
    , lower=ifelse(lower<0, 0, lower)
    , upper=improve_revised+se*1.96
    , upper=ifelse(upper>1, 1, upper)
  )


boot_results = lapply(1:10, function(x){
  comb_d[sample(1:nrow(comb_d), replace=T),] %>%
    subset(!is.na(err_quant))%>%
    subset(revised==1) %>%
    mutate(err_quant=round(err_quant))%>%
    group_by(err_quant) %>%
    mutate(
      , tot_d = length(unique(dataset))
    ) %>%
    group_by(err_quant, dataset) %>%
    mutate(
      , p=1/(n()*tot_d)
    ) %>%
    group_by(err_quant) %>%
    summarize(
      , tot_p=sum(p)
      
      , improve_revised_unweighted = mean(improve, na.rm=T)
      , improve_revised=sum(improve*p, na.rm=T)
    ) 
}) %>%
  do.call(rbind, .) %>%
  group_by(err_quant) %>%
  summarize(
      n=n()
    , improve_revised_se = sd(improve_revised)
    , improve_revised_unweighted_se=sd(improve_revised_unweighted)
    , improve_revised_boot = mean(improve_revised)
    , improve_revised_unweighted_boot = mean(improve_revised_unweighted)
  )

sum_agg = comb_d %>%
  subset(revised==1) %>%
  group_by(err_quant) %>%
  summarize(
    improve_revised = mean(improve, na.rm=T)
  ) %>%
  merge(boot_results, by="err_quant")  %>%
  mutate(
    lower = improve_revised-improve_revised_se*1.96
    , upper =improve_revised+improve_revised_se*1.96
  )

sum_agg %>%
  ggplot(aes(x=err_quant, y=improve_revised)) +
  geom_point(size=1) +
  geom_hline(yintercept=0.5, linetype="dashed")+
  geom_errorbar(aes(ymin=lower
                    , ymax=upper), width=0.0) +
  ylim(c(0,1)) + 
  nice_theme() +
  scale_x_continuous( expand = c(0,0.7), )

ggsave("../Figures/by_quant_improve_revised.png", width=2, height=1.9)

### by dataset
sum_d %>%
  ggplot(aes(x=err_quant, y=improve_revised, group=dataset)) +
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
ggsave("../Figures/appendix_By_quant_by_dataset.png", width=4.1, height=2.6)

group_d %>%
  group_by(dataset) %>%
  summarize(
    q=length(unique(task))
  )


