rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)
# DescTools gives us the sample variance estimar (biased estimator of sample variance), which is what we want
#install.packages("DescTools")
library(DescTools)

source("0a_data_preparation.R")
source("0b_helper_functions.R")

mycut = function(x) {
  breaks=quantile(x, probs=seq(0,1,by=0.25))
  out=sapply(x, function(z){
    max(which(breaks<z))
  })
  out[!is.finite(out)]=1
  out
}

mysetupvar="a12345"

cols=c(  "pre_influence","post_influence","truth","task"
       , "network", "trial", "dataset", "group_id"
       , "subject","confidence"
       )


out_d = rbind(
    lorenz_2011[, cols] %>% as.data.frame
  , becker_2017[, cols] %>% as.data.frame
  , gurcay_2015[, cols] %>% as.data.frame
  , becker_2019[, cols] %>% as.data.frame
  , silver_2021[, cols] %>% as.data.frame
  , becker_2020[, cols] %>% as.data.frame
) %>% 
  subset(!is.na(pre_influence) & !is.na(post_influence)) %>%
  mutate(
      pre_indy_error = (pre_influence - truth)^2
    , post_indy_error = (post_influence - truth)^2
    , delta_indy_error = post_indy_error - pre_indy_error
    , delta_indy_opinion = (post_influence - pre_influence)/(pre_influence - truth)
  ) %>%
  group_by(task, trial, dataset, network) %>%
  mutate(
      pre_mu = mean(pre_influence)
    , post_mu = mean(post_influence)
    , pre_s2 = VarN(pre_influence)
    , post_s2 = VarN(post_influence)
    , pre_crowd_error = (pre_mu - truth)^2
    , post_crowd_error = (post_mu - truth)^2
    , standardised_delta_crowd_error = (post_crowd_error - pre_crowd_error)/pre_s2
    , delta_crowd_opinion = (post_mu - pre_mu) / (pre_mu - truth)
    , standardised_mean_delta_indy_error = mean(delta_indy_error)/pre_s2
    , standardised_delta_s2 = (post_s2 - pre_s2)/pre_s2
    # , outlierPre = tukey_out(pre_influence)
    # , outlierPost = tukey_out(post_influence)
  ) %>%
  ungroup %>%
  mutate(
    standardised_delta_indy_error = delta_indy_error/pre_indy_error
    # , pre_log_err = log(abs(pre_influence-truth))
    , pre_sq_err_norm = ((pre_influence-truth)^2)/pre_s2
    # , pre_pct_err = abs(1-(pre_influence/truth))
    # , pre_log_pct_err = log(pre_pct_err + 0.00001)
    
    # , post_log_err = log(abs(post_influence-truth))
    , post_sq_err_norm = ((post_influence-truth)^2)/pre_s2
    # , post_pct_err = abs(1-(post_influence/truth))
    # , post_log_pct_err = log(post_pct_err + 0.00001)
    # ,ind_sd = sd
  ) %>% 
  subset(is.finite(pre_crowd_error) & is.finite(post_crowd_error))


# Only include changes in crowd and indy delta within X sds. 
#out_d_clean <- out_d %>%
#  filter(abs(standardised_delta_crowd_error) <= 10) %>%
#  filter(abs(standardised_mean_delta_indy_error) <= 10) %>%
#  filter(abs(delta_crowd_opinion) <= 10) %>%
#  filter(abs(standardised_delta_indy_error) <= 10)
  

# List of columns to plot in the desired order
columns_to_plot <- c('delta_crowd_opinion', 
                     'delta_indy_opinion')

# Define custom labels for the subplots
custom_labels <- c(
  'delta_indy_opinion' = "Relative Change in Individual Opinion",
  'delta_crowd_opinion' = "Relative Change in Crowd Opinion"
)

# Function to calculate percentages
calculate_percentages <- function(x) {
  c(
    below = mean(x < 0, na.rm = TRUE),
    equal = mean(x == 0, na.rm = TRUE),
    above = mean(x > 0, na.rm = TRUE)
  ) * 100
}

stacking_order <- c("equal" , "above", "below")

# Reshape the data and calculate percentages
long_data <- out_d %>%
  select(all_of(columns_to_plot)) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "value") %>%
  mutate(variable = factor(variable, levels = columns_to_plot),
         value_category = case_when(
           value < 0 ~ "below",
           value == 0 ~ "equal",
           value > 0 ~ "above"
         ) %>% factor(levels = stacking_order))

percentages <- long_data %>%
  group_by(variable) %>%
  summarize(
    pct = list(calculate_percentages(value)),
  ) %>%
  unnest_wider(pct)

color_improve <- "#9ca5e1" 
color_zero <- "darkgrey"
color_worse <- "#fb5f7e"


# Define color palette
color_palette <- c("below" = color_improve, "equal" = color_zero, "above" = color_worse)

# Create the faceted plot with color-coded bars and annotations
ggplot() +
  geom_histogram(data = long_data, aes(x = value, fill = value_category), bins = 50, color = "black") +
  geom_text(data = percentages, 
            aes(x = -2.5, y = Inf, 
                label = sprintf("Below Zero: %.1f%%", below)),
            hjust = 0, vjust = 1.5, size = 3, color = color_improve, fontface="bold") +
  geom_text(data = percentages, 
            aes(x = 0, y = Inf, 
                label = sprintf("Equal to Zero: %.1f%%", equal)),
            hjust = 0.5, vjust = 1.5, size = 3, color = color_zero, fontface="bold") +
  geom_text(data = percentages, 
            aes(x = 2.5, y = Inf, 
                label = sprintf("Above Zero: %.1f%%", above)),
            hjust = 1, vjust = 1.5, size = 3, color = color_worse, fontface="bold") +
  facet_wrap(~ variable, nrow = 5, scales = "free_y",
             labeller = as_labeller(custom_labels),
             strip.position = "bottom") +
  scale_fill_manual(values = color_palette) + 
  scale_y_continuous(expand = expansion(mult = c(0, 0.3))) +  # Add 20% extra space at the top
  xlim(-2.5, 2.5) +
  labs(x = "Standardised Values (truncated to ±2.5)",
       y = "Count") +
  theme_minimal() +
  theme(strip.text = element_text(size = 8),
        axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5),
        legend.position = "none",
        panel.grid.major.y = element_blank(),  # Remove major horizontal gridlines
        panel.grid.minor.y = element_blank())

ggsave("../Figures/delta_error_histograms_deltas.png", dpi=600, bg="#ffffff")
