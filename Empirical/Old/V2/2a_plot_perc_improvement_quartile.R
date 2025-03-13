rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(sdamr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)
library(afex) # mixed effects models
library(viridis) # colours
library(RColorBrewer) # colours
library("ggsci")

source("Scripts/1a_group_summaries.R")
source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")


# dataset_list = unique(group_d$dataset)
# 
# for (var in dataset_list) {
#   # plot the mean individual improvement, grouped by quartile
#   plot_quartile = subset(out_d, dataset == var) %>%
#     arrange(network)
#   print(ggplot(data = plot_quartile,
#                aes(x=error_quartile, y=delta_err, fill=network, group=network)) +
#           stat_summary(fun.y="mean", geom="bar", position=position_dodge()) +
#           ggtitle(paste0(var, " indv error x quartile"))+
#           labs(x="Error Quartile",
#                y="Individual Change") +
#           nice_theme())
#   
  # ggsave(paste0("figures/quartiles/no_inf/", var, "_mean_error_change.png"))
  
  # calculate the probability of improving - proportion of each individual who's error < 0 for each dataset/network/error_quartile
  # plot_improvement_likelihood = subset(out_d, dataset == var) %>%
  #   group_by(network, error_quartile) %>%
  #   summarize(improvement_likelihood = sum(not_worse)/n()) %>%
  #   ungroup %>%
  #   arrange(network)
  # 
  # print(ggplot( data=plot_improvement_likelihood,
  #               aes(x=error_quartile, y=improvement_likelihood, fill=network, group=network)) +
  #         geom_bar(stat="identity", position = 'dodge') +
  #         ggtitle(paste0(var, " % not worse x quartile"))+
  #         labs(x="Error Quartile",
  #              y="percentage indiv not worse") + 
  #         nice_theme())
  
  # ggsave(paste0("figures/quartiles/no_inf/", var, "_improvement_likelihood.png"))
  
  # plot_revised_improvement = subset(out_d, dataset == var) %>%
  #   group_by(network, error_quartile) %>% 
  #   summarise(
  #     revised_improvement = sum(revised[improve==1])/sum(revised)
  #   ) %>% 
  #   ungroup
  #   
  # print(ggplot( data=plot_revised_improvement,
  #               aes(x=error_quartile, y=revised_improvement, fill=network, group=network)) +
  #         geom_bar(stat="identity", position = 'dodge') +
  #         ggtitle(paste0(var, " IF REVISED % improved x quartile"))+
  #         labs(x="Error Quartile",
  #              y="percentage indiv improved") + 
  #         nice_theme())
  
  
  
}


# out_d %>%
#   ggplot(aes(x=error_quartile, y=improve, color=network, group=network)) +
#   stat_summary(fun.y="mean", geom="point") +
#   facet_grid(~dataset)
# 
# plot_revised_improvement = out_d %>%
#   group_by(dataset, network, error_quartile) %>% 
#   summarise(
#     revised_improvement = sum(revised[improve==1])/sum(revised)
#   ) %>% 
#   ungroup %>%
#   ggplot( data=plot_revised_improvement,
#               aes(x=error_quartile, y=revised_improvement, fill=network, group=network)) +
#         geom_bar(stat="identity", position = 'dodge') +
#         ggtitle(paste0(var, " IF REVISED % improved x quartile"))+
#         labs(x="Error Quartile",
#              y="percentage indiv improved") + 
#         nice_theme()
# 
# plot_revised_bars = out_d %>%
#   group_by(dataset, network, error_quartile) %>% 
#   summarise(
#     revised_improvement = sum(revised[improve==1])/sum(revised)
#   ) %>% 
#   ungroup
# 
# plot_revised_bars %>%
#   ggplot(
#     aes(x=error_quartile, y=revised_improvement, fill=network, group=network)) +
#         geom_bar(stat="identity", position = 'dodge') +
#         ggtitle(paste0(var, " IF REVISED % improved x quartile"))+
#         labs(x="Error Quartile",
#              y="percentage indiv improved") + 
#         nice_theme() +
#   facet_wrap(~dataset)


library("scales")
show_col(pal_npg("nrc")(3))
colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF", solo = "#A9A9A9")

unique(out_d$network)



beckertheme =   theme(panel.background=element_rect(fill="white", color="black", size=1.1), 
                      axis.text=element_text(size=rel(1), color="black"), 
                      strip.text=element_text(size=rel(1.1)), 
                      legend.text=element_text(size=rel(1.1)), strip.background=element_blank(),
                      title=element_text(size=rel(1.1)),
                      panel.grid=element_blank(),
                      plot.title=element_text(hjust=0.5))

############### new analysis and plots ###################
data = out_d %>%
  group_by(dataset, network, group_id, error_quartile) %>%
  summarise(
    group_id = unique(group_id)
    , error_quartile = unique(error_quartile)
    , pct_not_worse = sum(not_worse) / n()
    , mu_ind_change = mean(delta_err)
    , pct_revised_improved = sum(improve[revised == 1])/sum(revised)
  )

dx1=group_d %>%
  # subset(network != "solo") %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarise(
    mu_ind_change = mean(mu_ind_change)
  ) 


data_sum = data %>% 
  group_by(dataset, network, error_quartile) %>%
  summarySE(
    measurevar = "mu_ind_change"
    , groupvars = c("dataset", "network", "error_quartile")
    , boot.trials = 1000
  )

data_sum = data.table::data.table(data_sum)


data_sum[,y_min := min(mu_ind_change), by = dataset]
data_sum[,y_max := max(mu_ind_change) * 5, by = dataset]
#data_sum[,y_max := max(mu_ind_change) + (max(mu_ind_change) - min(mu_ind_change)), by = dataset]
data_sum[,y_min := min(mu_ind_change) * 1.2, by = dataset]
data_sum[,y_max := 0 + abs(min(mu_ind_change)* 1.2), by = dataset]

data_sum %>%
  ggplot(
    aes(x=error_quartile, y=mu_ind_change, fill=network, group=network)) + 
    geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
    geom_linerange(
      aes(ymax = mu_ind_change+bootci, ymin= mu_ind_change-bootci)
      , position = position_dodge(width = 0.9)
      ) +
  labs(x="Error Quartile",
       y="Mean error change") +
  beckertheme +
  facet_wrap(~dataset, scales = "free_y") +
  geom_blank(aes(y = y_min)) +
  geom_blank(aes(y = y_max)) +
  scale_fill_manual(values=colors) + 
  theme(legend.position="none") + 
  theme(aspect.ratio = .75)


ggsave(paste0("Figures/", "figure_5_quartile_.png"), width = 4, height = 3, dpi = 1000)


codes = cbind(c(1, 0, 0, 0),
              c(0, 0, 1, 0),
              c(0, 0, 0, 1))

colnames(codes) <- c("decentralized","centralized", "discussion")
contrasts(data$network) <- codes
contrasts(data$network)
data$error_quartile = as.factor(data$error_quartile)
contrasts(data$error_quartile) = contr.sum(4)
contrasts(data$error_quartile)




modr = afex::lmer(mu_ind_change ~ network * error_quartile + (1 | dataset / group_id), data=data)
summary(modr)

data_q1 = subset(data, error_quartile == 1)
modq1 = afex::lmer(mu_ind_change ~ network + (1 | dataset), data=data_q1)
summary(modq1)

data_q2 = subset(data, error_quartile == 2)
modq2 = afex::lmer(mu_ind_change ~ network + (1 | dataset), data=data_q2)
summary(modq2)

data_q3 = subset(data, error_quartile == 3)
modq3 = afex::lmer(mu_ind_change ~ network + (1 | dataset), data=data_q3)
summary(modq3)

data_q4 = subset(data, error_quartile == 4)
modq4 = afex::lmer(mu_ind_change ~ network + (1 | dataset), data=data_q4)
summary(modq4)

# tests and summaries 

tdat <- data.frame(predicted=predict(modr), residual = residuals(modr))
ggplot(tdat,aes(x=predicted,y=residual)) + geom_point() + geom_hline(yintercept=0, lty=3)

tdat <- data.frame(predicted=predict(modr), residual = residuals(modr), crowd=data$group_id)
ggplot(tdat,aes(x=predicted,y=residual, colour=crowd)) + geom_point() + geom_hline(yintercept=0, lty=3) + theme(legend.position = "none")


ggplot(tdat,aes(x=residual)) + geom_histogram(bins=200, color="black")


pairs(emmeans(modr, ~ network*error_quartile), simple = "each", combine = TRUE, adjust = "none")
emmeans(modr, specs = pairwise ~ network|error_quartile)


