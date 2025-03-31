# rm(list=ls());gc()
library(ggplot2)
library(tidyverse,warn.conflicts = F, quietly = T)


if(!exists("mysetupvar")){
  source("1a_group_summaries.R")
  source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")
}


processed_data$err_quant_round = round(processed_data$err_quant)

boots=1000
pb = txtProgressBar(min = 0, max = boots, initial = 0, style=3) 
boot_results_fig3right = lapply(1:boots, function(x){
  setTxtProgressBar(pb,x)
  processed_data[sample(1:nrow(processed_data), replace=T),] %>%
    subset(!is.na(err_quant))%>%
    subset(network!="Solo") %>%
    subset(revised==1) %>%
    group_by(err_quant_round) %>%
    mutate(
      , tot_d = length(unique(dataset))
    ) %>%
    group_by(err_quant_round, dataset) %>%
    mutate(
      , p=1/(n()*tot_d)
    ) %>%
    group_by(err_quant_round) %>%
    summarize(
      , tot_p=sum(p)
      , improve_revised_unweighted = mean(improve, na.rm=T)
      , improve_revised=sum(improve*p, na.rm=T)
      , revised_unweighted=mean(revised, na.rm=T)
      , revised=sum(revised*p, na.rm=T)
    ) 
}) %>%
  do.call(rbind, .) %>%
  group_by(err_quant_round) %>%
  summarize(
      n=n()
    , improve_revised_se = sd(improve_revised)
    , improve_revised_unweighted_se=sd(improve_revised_unweighted)
    , improve_revised_boot = mean(improve_revised)
    , improve_revised_unweighted_boot = mean(improve_revised_unweighted)
  )
close(pb)


boot_results_fig3right %>%
  mutate(
      improve_revised = improve_revised_boot
    , lower = improve_revised-improve_revised_se*1.96
    , upper =improve_revised+improve_revised_se*1.96
  ) %>%
  ggplot(aes(x=err_quant_round, y=improve_revised)) +
  geom_point(size=1) +
  geom_hline(yintercept=0.5, linetype="dashed", color="#AAAAAA") +
  geom_errorbar(aes(ymin=lower
                    , ymax=upper), width=0.0) +
  scale_y_continuous(
    expand = c(0.025,0)
    , lim=c(0.35,0.89)
    , breaks=seq(0.4, 0.8, by=0.1)
    ) +
  nice_theme() +
  theme(axis.ticks.x = element_blank())+
  scale_x_continuous( expand = c(0,0.7) )

ggsave("../Figures/Fig3.3_RIGHT_raw.png", width=2, height=1.9)
