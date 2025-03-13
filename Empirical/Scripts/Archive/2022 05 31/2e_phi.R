### set working directory to Empirical

rm(list=ls());gc()
library(ggplot2)
library(tidyverse,warn.conflicts = F, quietly = T)

source("Scripts/1a_group_summaries.R")


beckertheme =   theme(panel.background=element_rect(fill="white", color="black", size=1.1), 
                      axis.text=element_text(size=rel(1), color="black"), 
                      strip.text=element_text(size=rel(1.1)), 
                      legend.text=element_text(size=rel(1.1)), strip.background=element_blank(),
                      title=element_text(size=rel(1.1)),
                      panel.grid=element_blank(),
                      plot.title=element_text(hjust=0.5),
                      aspect.ratio = 1)


group_d %>%
  mutate(
    prop_toward = round(prop_toward, 1)
  ) %>%
  subset(
    dataset %in% c("becker 2020","gurcay 2015")
  ) %>%
  ggplot(aes(x=prop_toward, y=mu_ind_change)) +
  facet_wrap(.~dataset) +
  stat_summary(fun="mean", geom="point") +
  geom_hline(yintercept=0, linetype="dashed") +
  labs(x="Calibration", y="Change in Avg. Individual Error") +
  beckertheme
ggsave("Figures/PHI_ind_error_by.png")



group_d %>%
  mutate(
    prop_toward = round(prop_toward, 1)
  ) %>%
  subset(
    dataset %in% c("becker 2020","gurcay 2015")
  ) %>%
  ggplot(aes(x=prop_toward, y=pct_not_worse)) +
  facet_wrap(.~dataset) +
  stat_summary(fun="mean", geom="point") +
  geom_hline(yintercept=0.5, linetype="dashed") +
  labs(x="Calibration", y="% of Individuals Not Worse") +
  ylim(c(0,1)) +
  beckertheme
ggsave("Figures/PHI_pct_not_worse.png")


group_d %>%
  subset(
    dataset %in% c("becker 2020","gurcay 2015")
  ) %>%
  ggplot(aes(x=prop_toward, y=crowd_change_mu)) +
  facet_wrap(.~dataset) +
  stat_summary(fun="mean", geom="point") +
  geom_hline(yintercept=0, linetype="dashed") +
  geom_vline(xintercept=0.5, linetype="dashed") +
  labs(x="Calibration", y="Change in (Group) Error of Mean") +
  beckertheme
ggsave("Figures/PHI_change_group_error.png")


group_d %>%
  subset(
    dataset %in% c("becker 2020","gurcay 2015")
  ) %>%
  mutate(
     phi_greater = prop_toward<0.5
  ) %>%
  group_by(phi_greater, dataset) %>%
  summarize(
    crowd_improvement=mean(as.numeric(crowd_improvement))
  ) %>%
  ggplot(aes(x=phi_greater, y=as.numeric(crowd_improvement))) +
  facet_wrap(.~dataset) +
  geom_point() +
  geom_hline(yintercept=0.5, linetype="dashed") +
  labs(x="Calibration", y="% Groups Not Worse") +
  beckertheme +
  ylim(c(0.3,0.7))
ggsave("Figures/CALIBRATION_change_group_error_PCT.png")
