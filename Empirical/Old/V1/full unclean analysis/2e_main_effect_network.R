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
colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF", solo = "#A9A9A9")



data_sum = out_d %>%
  group_by(network) %>%
  summarySE(
    measurevar = "delta_err"
    , groupvars = c("network")
    , boot.trials = 1000
  )

data_sum = data.table::data.table(data_sum)
data_sum[,y_min := min(delta_err) * 1.1, by = network]
data_sum[,y_max := 0 + abs(min(delta_err)* 1.1), by = network]

data_sum %>%
  ggplot(
    aes(x = network, y = delta_err, fill = network)
  ) + 
  geom_bar(stat = "identity", position = position_dodge(width = .9)) +
  geom_linerange(
    aes(ymax = delta_err+bootci, ymin= delta_err-bootci),
    position = position_dodge(width = 0.9)
  ) +
  ggtitle("Change in error x Network") +
  # geom_hline(yintercept=mean(data_sum$delta_err), linetype="dashed", color="#333333") +
  labs(x="Network", 
       y="Mean Error Change") + 
  beckertheme +
  ylim(-0.5, 0)


codes = cbind(c(1, 0, 0, 0),
              c(0, 0, 1, 0),
              c(0, 0, 0, 1))

colnames(codes) <- c("decentralized","centralized", "discussion")

contrasts(out_d$network) <- codes
levels(out_d$network)
contrasts(out_d$network)

modr = afex::lmer(delta_err ~ network + (1 | dataset / task / group_id), data=out_d)
summary(modr)
  

data_sum_group = group_d %>%
  group_by(network) %>%
  summarySE(
    measurevar = "mu_ind_change"
    , groupvars = c("network")
    , boot.trials = 1000
  )

data_sum_group = data.table::data.table(data_sum)
data_sum_group[,y_min := min(delta_err) * 1.1, by = network]
data_sum_group[,y_max := 0 + abs(min(delta_err)* 1.1), by = network]

data_sum_group %>%
  ggplot(
    aes(x = network, y = mu_ind_change, fill = network)
  ) + 
  geom_bar(stat = "identity", position = position_dodge(width = .9)) +
  geom_linerange(
    aes(ymax = mu_ind_change+bootci, ymin= mu_ind_change-bootci),
    position = position_dodge(width = 0.9)
  ) +
  ggtitle("Change in error x Network (trial level") +
  # geom_hline(yintercept=mean(data_sum$delta_err), linetype="dashed", color="#333333") +
  labs(x="Network", 
       y="Mean Error Change") + 
  beckertheme +
  scale_fill_manual(values = colors)


codes = cbind(c(1, 0, 0, 0),
              c(0, 0, 1, 0),
              c(0, 0, 0, 1))

colnames(codes) <- c("decentralized","centralized", "discussion")

contrasts(group_d$network) <- codes
levels(group_d$network)
contrasts(group_d$network)

modg = afex::lmer(mu_ind_change ~ network + (1 | dataset / task), data=group_d)
summary(modg)


sub_dat = subset(group_d, network!= "solo")
levels(sub_dat$network) = droplevels(sub_dat$network)
levels(sub_dat$network)
contrasts(sub_dat$network)

codes2 = cbind(c(1, 0, 0),
              c(0, 0, 1))

colnames(codes2) <- c("decentralized", "discussion")

contrasts(sub_dat$network) <- codes2

mod3 = afex::lmer(mu_ind_change ~ network, data=sub_dat)
  