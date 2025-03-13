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

modr = lm(mu_ind_change ~ network - 1, data = group_d)
summary(modr)

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

emms = emmeans(mod3, specs = ~ network)
test(emms, null = 0)

mods = lm(mu_ind_change ~ network - 1, data = sub_dat)
summary(mods)

emms = emmeans(mods, specs = ~ network)
test(emms, null = 0)

debug_contr_error <- function (dat, subset_vec = NULL) {
  if (!is.null(subset_vec)) {
    ## step 0
    if (mode(subset_vec) == "logical") {
      if (length(subset_vec) != nrow(dat)) {
        stop("'logical' `subset_vec` provided but length does not match `nrow(dat)`")
      }
      subset_log_vec <- subset_vec
    } else if (mode(subset_vec) == "numeric") {
      ## check range
      ran <- range(subset_vec)
      if (ran[1] < 1 || ran[2] > nrow(dat)) {
        stop("'numeric' `subset_vec` provided but values are out of bound")
      } else {
        subset_log_vec <- logical(nrow(dat))
        subset_log_vec[as.integer(subset_vec)] <- TRUE
      } 
    } else {
      stop("`subset_vec` must be either 'logical' or 'numeric'")
    }
    dat <- base::subset(dat, subset = subset_log_vec)
  } else {
    ## step 1
    dat <- stats::na.omit(dat)
  }
  if (nrow(dat) == 0L) warning("no complete cases")
  ## step 2
  var_mode <- sapply(dat, mode)
  if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
  var_class <- sapply(dat, class)
  if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
    stop("matrix variables with 'AsIs' class must be 'numeric'")
  }
  ind1 <- which(var_mode %in% c("logical", "character"))
  dat[ind1] <- lapply(dat[ind1], as.factor)
  ## step 3
  fctr <- which(sapply(dat, is.factor))
  if (length(fctr) == 0L) warning("no factor variables to summary")
  ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
  dat[ind2] <- lapply(dat[ind2], base::droplevels.factor)
  ## step 4
  lev <- lapply(dat[fctr], base::levels.default)
  nl <- lengths(lev)
  ## return
  list(nlevels = nl, levels = lev)
}

debug_contr_error(sub_dat)



