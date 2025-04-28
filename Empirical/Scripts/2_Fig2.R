# rm(list=ls());gc()
library(ggplot2)
library(tidyverse,warn.conflicts = F, quietly = T)


if(!exists("mysetupvar")){
  source("1a_group_summaries.R")
  source("https://raw.githubusercontent.com/joshua-a-becker/RTools/master/beckerfunctions.R")
}


### main text regression results

### OVERALL RESULTS FOR d>0


### AS MATHEMATICALLY REQUIRED...
### CHANGE IND ERROR < CHANGE GROUP ERROR **when** VARIANCE DECREASES
### CHANGE IND ERROR > CHANGE GROUP ERROR **when** VARIANCE INCREASES
table(group_data$ind_change<group_data$crowd_change, group_data$s_squared_change<0)

table(group_data$s_squared_change==0)

### 2336 trials total
# 2100 trials have decreasing SD
# 209 have increasing sd
# 27 have no change at all 

with(subset(group_data, s_squared_change!=0),
  table((s_post < s_pre), s_squared_change<0)
)

### 100% have difference-in-normalized-error in [0,1]
with(subset(group_data, s_squared_change!=0),
     table(delta_err_math>=0 & delta_err_math<=1)
)

### ind change ALWAYS < group change WHEN sd change < 0
with(subset(group_data, s_squared_change!=0),
     table(ind_change<crowd_change, s_squared_change<0)
)


### regression
### INTERCEPT = -0.6388848  (se = 0.0047062)
### COEFFICIENT = 0.998097 (se = 0.0009545 )
group_data %>%
  subset(s_squared_change<0) %>%
  subset(
    !is.na(ind_change_normalized) & !is.na(crowd_change_normalized)
    & !is.nan(ind_change_normalized) & !is.nan(crowd_change_normalized)
    & is.finite(ind_change_normalized) & is.finite(crowd_change_normalized)
  )%>%
  lm(ind_change_normalized ~ crowd_change_normalized, .) %>%
  summary


## conf interval on intercept
-0.6388848+0.004706*1.960
-0.6388848
-0.6388848-0.004706*1.960

## conf interval on slope
0.9981+0.0009545*1.960
0.9981
0.9981-0.0009545*1.960


### but do individuals improve?

group_data %>%
  subset(s_squared_change!=0) %>%
  mutate(change_diversity = s_squared_change<0) %>%
  group_by(change_diversity) %>%
  summarize(
      mean(ind_change<0)
    , N=n()
  )


### Fig 2 - MAIN (regression figure)
group_data %>%
  ggplot(aes(x=crowd_change_normalized, y=ind_change_normalized))+
  geom_point(size=0.01, shape=20, aes(color=s_squared_change<0)) +
  xlim(c(-10,10)) +
  ylim(c(-10,10)) +
  geom_abline(intercept=-0, slope=0, linetype="dashed", color="grey") +
  geom_vline(xintercept=0, linetype="dashed", color="grey") +
  geom_abline(intercept=-0, slope=1, linetype="dashed", color="red") +
  geom_abline(intercept=-1, slope=1, linetype="dashed", color="red") +
  grafify::scale_color_grafify(palette="okabe_ito")+
  guides(color=F)+
  nice_theme()


ggsave("../Figures/Fig2_MAIN.png", width=2.5, height=2.2, dpi=1000)




### Fig 2 - INSET (regression close up)
group_data %>%
  ggplot(aes(x=crowd_change_normalized, y=ind_change_normalized))+
  geom_point(size=0.01, shape=20, aes(color=s_squared_change<0)) +
  xlim(c(-2,2)) +
  ylim(c(-2,2)) +
  geom_abline(intercept=-0, slope=1, linetype="dashed", color="red") +
  geom_abline(intercept=-1, slope=1, linetype="dashed", color="red") +
  grafify::scale_color_grafify(palette="okabe_ito")+
  guides(color=F)+
  nice_theme()


ggsave("../Figures/Fig2_INSET.png", width=2.2, height=2.2)
