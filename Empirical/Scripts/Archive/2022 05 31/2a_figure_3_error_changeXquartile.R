rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(sdamr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)
library(afex) # mixed effects models

source("1a_group_summaries.R")
source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")


# colors for plotting
colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF", solo = "#A9A9A9")

beckertheme =   theme(panel.background=element_rect(fill="white", color="black", size=1.1), 
                      axis.text=element_text(size=rel(1), color="black"), 
                      strip.text=element_text(size=rel(1.1)), 
                      legend.text=element_text(size=rel(1.1)), strip.background=element_blank(),
                      title=element_text(size=rel(1.1)),
                      panel.grid=element_blank(),
                      plot.title=element_text(hjust=0.5),
                      aspect.ratio = .75)

############### new analysis and plots ###################
data = out_d %>%
  subset(dataset!="silver 2021") %>% ## no control group
  subset(dataset!="becker 2020") %>% ## no control group
  group_by(dataset, network, group_id, error_quartile) %>%
  summarise(
    group_id = unique(group_id)
    , error_quartile = unique(error_quartile)
    , pct_not_worse = sum(not_worse) / n()
    , mu_ind_change = mean(delta_err)
    , pct_revised_improved = sum(improve[revised == 1])/sum(revised)
  )


data_sum = data %>% 
  group_by(dataset, network, error_quartile) %>%
  summarySE(
    measurevar = "mu_ind_change"
    , groupvars = c("dataset", "network", "error_quartile")
    , boot.trials = 1000
  )

data_sum = data.table::data.table(data_sum)

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
  ggtitle("mean change in individual error")+
  labs(x="Error Quartile",
       y="Mean error change") +
  beckertheme +
  facet_wrap(~dataset, scales = "free_y") +
  geom_blank(aes(y = y_min)) +
  geom_blank(aes(y = y_max)) +
  scale_fill_manual(values=colors)


#ggsave(paste0("Figures/", "quartile_x6x4x1000.png"), width = 6, height = 4, dpi = 1000)


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

# tests and summaries 

tdat <- data.frame(predicted=predict(modr), residual = residuals(modr))
ggplot(tdat,aes(x=predicted,y=residual)) + geom_point() + geom_hline(yintercept=0, lty=3)

tdat <- data.frame(predicted=predict(modr), residual = residuals(modr), crowd=data$group_id)
ggplot(tdat,aes(x=predicted,y=residual, colour=crowd)) + geom_point() + geom_hline(yintercept=0, lty=3) + theme(legend.position = "none")


ggplot(tdat,aes(x=residual)) + geom_histogram(bins=200, color="black")

# pairwise summaries
emmeans(modr, specs = pairwise ~ network|error_quartile)


# tests for each individual quartile

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




