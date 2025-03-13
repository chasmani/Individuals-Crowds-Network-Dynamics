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
  

#reformat data
data_sum_group = group_d %>%
  group_by(network) %>%
  summarySE(
    measurevar = "mu_ind_change"
    , groupvars = c("network")
    , boot.trials = 1000
  )

# plot data

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

# simple regression without the intercept 
modr = lm(mu_ind_change ~ network - 1, data = group_d)
summary(modr)


#####  same as the test above but subsets the data to remove the solo condition

sub_dat = subset(group_d, network != "solo")
sub_dat$network = droplevels(sub_dat$network)
levels(droplevels(sub_dat$network))
levels(sub_dat$network)
contrasts(sub_dat$network)

codes2 = cbind(c(1, 0, 0),
              c(0, 0, 1))

colnames(codes2) <- c("decentralized", "discussion")

contrasts(sub_dat$network) <- codes2

contrasts(sub_dat$network)

sub_dat$network = as.factor(sub_dat$network)
mod3 = afex::lmer(mu_ind_change ~ network + (1 | dataset), data=sub_dat)
summary(mod3)

# regression without the intercept
mods = lm(mu_ind_change ~ network - 1, data = sub_dat)
summary(mods)




