rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(sdamr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)
library(afex)
library(emmeans)

source("Scripts/1a_group_summaries.R")
source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")


beckertheme =   theme(panel.background=element_rect(fill="white", color="black", size=1.1), 
                      axis.text=element_text(size=rel(1), color="black"), 
                      strip.text=element_text(size=rel(1.1)), 
                      legend.text=element_text(size=rel(1.1)), strip.background=element_blank(),
                      title=element_text(size=rel(1.1)),
                      panel.grid=element_blank(),
                      plot.title=element_text(hjust=0.5))

# group_d %>%
#   subset(network != "solo") %>%
#   group_by(dataset, network, crowd_improvement) %>%
#   summarise(
#     mean_perc = mean(pct_not_worse)
#   ) %>%
#   ggplot(
#     aes(crowd_improvement, mean_perc, color = network)) +
#   geom_point() + 
#   # geom_text(aes(label=network),hjust=-.2, vjust=0) +
#   ggtitle("Inidividual % Not Worse")+
#   geom_hline(yintercept=0.5, linetype="dashed", color="#333333") +
#   geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
#   labs(x="MEAN Crowd Error: Better or Worse", 
#        y="MEAN % of indv \nnot getting worse per network") + 
#   facet_wrap(~dataset) +
#   nice_theme()


dx1=group_d %>%
  # subset(network != "solo") %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarise(
    mu_ind_change = mean(mu_ind_change)
  ) 


dx2=group_d %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarySE(
    measurevar="mu_ind_change"
    , groupvars=c("dataset","network","crowd_improvement")
  ) 

dx1 %>% 
  ggplot(
    aes(x=crowd_improvement, y=mu_ind_change, color = network)) +
  geom_point(position=position_jitter(h=0.15,w=0.15)) +
  # geom_text(aes(label=network),hjust=-.2, vjust=0) +
  ggtitle("Change in error x Crowd Outcome")+
  geom_hline(yintercept=0, linetype="dashed", color="#333333") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x="MEAN Crowd Error: Better or Worse", 
       y="MEAN individual error change") + 
  facet_wrap(~dataset, scales = "free") +
  nice_theme()

dx2 %>% 
  ggplot(
    aes(x=crowd_improvement, y=mu_ind_change, color = network)) +
  geom_point(position=position_jitter(w=0.15)) +
  # geom_text(aes(label=network),hjust=-.2, vjust=0) +
  ggtitle("Change in error x Crowd Outcome")+
  geom_hline(yintercept=0, linetype="dashed", color="#333333") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x="MEAN Crowd Error: Better or Worse", 
       y="MEAN individual error change") + 
  facet_wrap(~dataset, scales = "free") +
  nice_theme()




data_sum = group_d %>%
  # subset(network != "solo") %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarySE(
    measurevar="mu_ind_change"
    , groupvars = c("dataset", "network", "crowd_improvement")
    , boot.trials = 1000
  ) 

data_sum = data.table::data.table(data_sum)
data_sum[,y_min := min(mu_ind_change) * 1.1, by = dataset]
data_sum[,y_max := 0 + abs(min(mu_ind_change)* 1.1), by = dataset]

colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF", solo = "#A9A9A9")
shapes = c(centralized = 19, decentralized = 19, discussion = 19, solo = 4)


data_sum %>%
  ggplot(
    aes(x=crowd_improvement, y=mu_ind_change, color = network, shape=network)) +
  scale_color_manual(values=colors) +
  scale_shape_manual(values=shapes) +
  geom_point(position = position_dodge(width=0.05), size = 2.5, alpha = 0.9) +
  geom_linerange(
    aes(ymax = mu_ind_change+bootci, ymin= mu_ind_change-bootci),
    position = position_dodge(width = 0.05)
    ) +
  ggtitle("Change in error x Crowd Outcome")+
  geom_hline(yintercept=0, linetype="dashed", color="#333333") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x="MEAN Crowd Error: Better or Worse", 
       y="MEAN individual error change") + 
  facet_wrap(~dataset, scales = "free_y") +
  geom_blank(aes(y = y_min)) +
  geom_blank(aes(y = y_max)) + 
  beckertheme

ggsave(paste0("Figures/", "crowd_outcome_none_1000.png"), dpi = 1000)
ggsave(paste0("Figures/", "crowd_outcome_5.5x4.5x100.png"), width = 5.5, height = 4.5, dpi = 1000)
ggsave(paste0("Figures/", "crowd_outcome_6x4.5x100.png"), width = 6, height = 4.5, dpi = 1000)
ggsave(paste0("Figures/", "crowd_outcome_x6x4x1000.png"), width = 6, height = 4, dpi = 1000)


summary = group_d %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarise(
    mean_ind_change = mean(mu_ind_change)
  )


# for (var in unique(group_d$dataset)) {
#   dat = subset(group_d, dataset == var & network != "solo") %>%
#     group_by(network, crowd_improvement) %>%
#     summarise(
#       mean_ind_change = mean(mu_ind_change)
#     )
#   print(
#     ggplot(data = dat,
#       aes(crowd_improvement, mean_ind_change, color = network)) +
#     geom_point() +
#     # geom_text(aes(label=network),hjust=-.2, vjust=0) +
#     ggtitle(var)+
#     geom_hline(yintercept=0, linetype="dashed", color="#333333") +
#     geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
#     labs(x="MEAN Crowd Error: Better or Worse", 
#          y="MEAN individual error change") + 
#     nice_theme())
#   
#     
# }

codes = cbind(c(1, 0, 0, 0),
              c(0, 0, 1, 0),
              c(0, 0, 0, 1))

colnames(codes) <- c("decentralized","centralized", "discussion")
contrasts(group_d$network) <- codes
               
contrasts(group_d$network)
contrasts(group_d$crowd_improvement)



modr = afex::lmer(mu_ind_change ~ network * crowd_improvement + (1 | dataset / task), data=group_d)
summary(modr)

pairs(emmeans(modr, ~ network + crowd_improvement), simple = "each", combine = TRUE, adjust = "none")
emmeans(modr, specs = pairwise ~ network|crowd_improvement)

tdat <- data.frame(predicted=predict(modr), residual = residuals(modr))
ggplot(tdat,aes(x=predicted,y=residual)) + geom_point() + geom_hline(yintercept=0, lty=3)

tdat <- data.frame(predicted=predict(modr), residual = residuals(modr), network=group_d$network)
ggplot(tdat,aes(x=predicted,y=residual, colour=network)) + geom_point() + geom_hline(yintercept=0, lty=3) + theme(legend.position = "none")


ggplot(tdat,aes(x=residual)) + geom_histogram(bins=200, color="black")



