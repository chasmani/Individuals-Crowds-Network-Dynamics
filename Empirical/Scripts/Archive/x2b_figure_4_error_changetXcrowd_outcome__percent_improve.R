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
                      plot.title=element_text(hjust=0.5),
                      aspect.ratio = 1)


data_sum = group_d %>%
  # subset(network != "solo") %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarySE(
      measurevar="pct_improve"
    , groupvars = c("dataset", "network", "crowd_improvement")
    , boot.trials = 1000
  ) 

# manipulating the y axis so each facet changes by the same formula, makes 
# symmetrical spacing on either side of y=0
data_sum = data.table::data.table(data_sum)
data_sum[,y_min := min(pct_improve) * 1.1, by = dataset]
data_sum[,y_max := 0 + abs(min(pct_improve)* 1.1), by = dataset]


colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF")
shapes = c(centralized = 19, decentralized = 19, discussion = 19)

data_sum %>% subset(network != "solo") %>%
  ggplot(
    aes(x=crowd_improvement, y=pct_improve, color = network, shape=network)) +
  scale_color_manual(values=colors) +
  scale_shape_manual(values=shapes) +
  geom_point(position = position_dodge(width=0.05), size = 2.5, alpha = 0.75) +
  geom_linerange(
    aes(ymax = pct_improve+bootci, ymin= pct_improve-bootci),
    position = position_dodge(width = 0.05)
    ) +
  geom_hline(yintercept=0.5, linetype="dashed", color="#333333") +
  #geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x="Mean Crowd Error: Better or Worse", 
       y="Mean Percentage\n Individuals Not Worse") + 
  facet_wrap(~dataset, scales = "free_y") +
  #geom_blank(aes(y = y_min)) +
  #geom_blank(aes(y = y_max)) + 
  beckertheme +
  ylim(c(0,1))

ggsave(paste0("../Figures/New Figures/Figure 4/", "PCT_INDIVID_IMRPOVED_X_crowd_outcome.png"), width = 6.5, height = 5, dpi = 1000)


codes = cbind(c(1, 0, 0, 0),
              c(0, 0, 1, 0),
              c(0, 0, 0, 1))

colnames(codes) <- c("decentralized","centralized", "discussion")
contrasts(group_d$network) <- codes


modr = afex::lmer(mu_ind_change ~ network * crowd_improvement + (1 | dataset / task), data=group_d)
summary(modr)

# pairwise comparisons of interaction
emmeans(modr, specs = pairwise ~ network|crowd_improvement)


# plotting the residuals of the mixed model
tdat <- data.frame(predicted=predict(modr), residual = residuals(modr))
ggplot(tdat,aes(x=predicted,y=residual)) + geom_point() + geom_hline(yintercept=0, lty=3)

tdat <- data.frame(predicted=predict(modr), residual = residuals(modr), network=group_d$network)
ggplot(tdat,aes(x=predicted,y=residual, colour=network)) + geom_point() + geom_hline(yintercept=0, lty=3) + theme(legend.position = "none")


ggplot(tdat,aes(x=residual)) + geom_histogram(bins=200, color="black")



