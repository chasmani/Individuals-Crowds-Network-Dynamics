hist(group_d$calibration)


## weighted avg
thisd= group_d %>% 
  mutate(
    cal=(round(calibration*3)/3)
  ) %>%
  subset(!is.na(cal)) %>%
  # group_by(cal) %>%
  # summarize(
  #     crowd_change_mu=median(crowd_change_mu)
  #   , mu_ind_change = median(mu_ind_change)
  # )%>%
  group_by(cal) %>%
  mutate(
    , tot_d = length(unique(dataset))
  ) %>%
  group_by(dataset, cal) %>%
  mutate(
    , p=1/(n()*tot_d)
  ) %>%
  group_by(cal) %>%
  mutate(
      group_improve = crowd_change_mu<0
    , mu_ind_change = median(mu_ind_change)
  )%>%
  summarize(
    , tot_p=sum(p)
    
    # , pct_improve_revised_unweighted = mean(pct_improve_revised, na.rm=T)
    # , pct_not_worse_unweighted = mean(pct_not_worse, na.rm=T)
    
    , group_improve = sum(group_improve*p)
    # , mu_ind_change = sum(mu_ind_change*p)
    , pct_improve_revised = sum(pct_improve_revised*p, na.rm=T)
    , pct_not_worse = sum(pct_not_worse*p, na.rm=T)
  ) 
  
  
group_d %>%
  mutate(cal=(round(calibration*4)/4)) %>%
  group_by(cal) %>%
  summarize(
    crowd_improve=mean(crowd_change_mu<=0)
    , pct_not_worse = mean(pct_not_worse)
  ) %>%
  # subset(network!="solo")%>%
  ggplot(aes(x=cal)) +
  geom_point(aes(y=crowd_improve)) +
  geom_point(aes(y=pct_not_worse), shape=2) +
  # geom_point(aes(y=pct_not_worse, linetype="individual")) +
  geom_hline(yintercept=0.5, linetype="dashed") +
  geom_vline(xintercept=0, linetype="dashed") + 
  # guides(line)
  ylim(c(0,1))+
  labs(y="change in error", x="empirical calibration", linetype="")+
  nice_theme()

glm(crowd_improvement ~ calibration*dataset, group_d, family="binomial") %>%
  summary()

glm(crowd_improvement ~ calibration, group_d %>% subset(dataset=="silver 2021"), family="binomial") %>%
  summary()

