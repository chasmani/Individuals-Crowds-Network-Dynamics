
data_sum = 
  out_d %>%
  group_by(dataset, network, group_id, error_quartile) %>%
  summarise(
      group_id = unique(group_id)
    , error_quartile = unique(error_quartile)
    , pct_not_worse = sum(not_worse) / n()
    , mu_ind_change = mean(delta_err)
    , pct_revised_improved = sum(improve[revised == 1])/sum(revised)
  ) 


result = data.frame()
for(nets in c("decentralized","centralized","discussion")) { 
for(this_quartile in c(1,2,3,4)) {
  
  
  
  mod = data_sum %>%
    subset(network%in%c(nets,"solo") & error_quartile==this_quartile
           & dataset %in% unique(data_sum$dataset[data_sum$network==nets])) %>% 
    mutate(
      count_dat=length(unique(dataset))
    )%>%
    group_by(dataset) %>%
    mutate(
      weight = (1 / length(mu_ind_change))/count_dat
    ) %>% 
    lm(
      mu_ind_change ~ network
      , weights = weight
      , data=.
    )
  
  
  outline = data.frame(network=nets
                       , quartile=this_quartile
                       , p.val=coef(summary(mod))[2,4]
                       , est=coef(summary(mod))[2,1]
                       , std.err = coef(summary(mod))[2,2]
                       , N = nobs(mod)
  )
  result = rbind(result, outline)
} }



result$p.val = round(result$p.val, 4)
result$est = round(result$est, 4)
result$std.err = round(result$std.err, 4)

result %>% format(scientific=F) %>%
  arrange(quartile)

result %>%
  ggplot(
    aes(x=quartile, y=est, fill=network, group=network)) + 
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  geom_linerange(
    aes(ymax = est+(1.96*std.err), ymin= est-(1.96*std.err))
    , position = position_dodge(width = 0.9)
  ) +
  labs(x="Error Quartile",
       y="Mean error change") +
  beckertheme +
  scale_fill_manual(values=colors)
