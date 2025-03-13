

out_d = rbind(
    lorenz_2011[, cols] %>% as.data.frame
  , becker_2017[, cols] %>% as.data.frame
  , gurcay_2015[, cols] %>% as.data.frame
  , becker_2019[, cols] %>% as.data.frame
) %>% 
  mutate(
      pre_influence = as.numeric(pre_influence)
    , post_influence = as.numeric(post_influence)
  ) %>%
  subset(!is.na(pre_influence) & !is.na(post_influence)) %>%
  group_by(task, trial, dataset, network) %>%
  mutate(
      mu1 = mean(pre_influence)
    , toward_truth = ifelse((pre_influence < mean(pre_influence) & mu1 <= truth) | (pre_influence > mu1 & mu1 >= truth), "Away","Toward")
  ) %>%
  ungroup %>%
  mutate(
    , pre_abs_err = abs(pre_influence-truth)
    , post_abs_err = abs(post_influence-truth)
    
    , pre_err = pre_abs_err
    , post_err = post_abs_err
    
    , delta_err = post_err - pre_err
  ) %>% 
  group_by(task, trial, dataset, network) %>%
  mutate(
      error_quartile = ntile(pre_err, 4)
  ) 


levels(out_d$network)

levels(out_d$network)[levels(out_d$network)=="decentralized"] = "Numeric (Decentralized)"
levels(out_d$network)[levels(out_d$network)=="centralized"] = "Numeric (Centralized)"
levels(out_d$network)[levels(out_d$network)=="NGT"] = "Decentralized Numeric"
levels(out_d$network)[levels(out_d$network)=="FTF"] = "Discussion"
levels(out_d$network)[levels(out_d$network)=="Numeric_exchange"] = "Numeric (Decentralized)"
levels(out_d$network)[levels(out_d$network)=="numeric exchange"] = "Numeric (Decentralized)"
levels(out_d$network)[levels(out_d$network)=="numeric_exchange"] = "Numeric (Decentralized)"
levels(out_d$network)[levels(out_d$network)=="IDEA"] = "Delphi"
levels(out_d$network)[levels(out_d$network)=="web_chat"] = "Discussion"
levels(out_d$network)[levels(out_d$network)=="discussion_dyad"] = "Discussion"
levels(out_d$network)[levels(out_d$network)=="discussion"] = "Discussion"
levels(out_d$network)[levels(out_d$network)=="static"] = "Numeric (Decentralized)"

group_d = out_d %>%
  group_by(task, trial, dataset, network) %>%
  summarize(
      truth = unique(truth)
    , N = n()
    
    # mean
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    
    # crowd mean error
    , crowd_pre_err_mu = abs(mu1/truth)
    , crowd_post_err_mu = abs(mu2/truth)
    
    # change in crowd error
    , crowd_change_mu = crowd_post_err_mu - crowd_pre_err_mu
    , crowd_improvement = crowd_change_mu < 0
    , crowd_not_worse = crowd_change_mu <= 0
    
    # change in average individual error
    , mu_ind_change = mean(delta_err)

  ) %>%
  ungroup



data_sum = group_d %>%
  # subset(network != "solo") %>%
  subset(!dataset%in%c("silver 2021","becker 2020")) %>%
  group_by(dataset, network, crowd_improvement) %>%
  summarySE(
    measurevar="mu_ind_change"
    , groupvars = c("dataset", "network", "crowd_improvement")
    , boot.trials = 1000
  ) 




# manipulating the y axis so each facet changes by the same formula, makes 
# symmetrical spacing on either side of y=0
data_sum = data.table::data.table(data_sum)
data_sum[,y_min := min(mu_ind_change) * 1.1, by = dataset]
data_sum[,y_max := 0 + abs(min(mu_ind_change)* 1.1), by = dataset]


colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF")
shapes = c(centralized = 19, decentralized = 19, discussion = 19)

data_sum %>% 
  subset(network != "solo") %>%
  subset(!dataset%in%c("silver 2021","becker 2020")) %>%
  ggplot(
    aes(x=crowd_improvement, y=mu_ind_change, color = network, shape=network)) +
  scale_color_manual(values=colors) +
  scale_shape_manual(values=shapes) +
  geom_point(position = position_dodge(width=0.05), size = 2.5, alpha = 0.75) +
  geom_linerange(
    aes(ymax = mu_ind_change+bootci, ymin= mu_ind_change-bootci),
    position = position_dodge(width = 0.05)
  ) +
  geom_hline(yintercept=0, linetype="dashed", color="#333333") +
  geom_vline(xintercept=0, linetype="dashed", color="#333333") + 
  labs(x="Mean Crowd Error: Better or Worse", 
       y="Mean Individual\n error change") + 
  facet_wrap(~dataset, scales = "free_y") +
  geom_blank(aes(y = y_min)) +
  geom_blank(aes(y = y_max)) + 
  beckertheme

ggsave(paste0("../Figures/New Figures/Figure 4/", "MEAN_IDIVID_ERROR_Xcrowd_outcome.png"), width = 5, height = 4, dpi = 1000)

