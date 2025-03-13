result = data.frame()
for(nets in unique(group_d$network)) {
  
  mod = group_d %>%
    subset(network == nets) %>% 
    mutate(
      count_dat=length(unique(dataset))
    )%>%
    group_by(dataset) %>%
    mutate(
      weight = (1 / length(mu_ind_change))/count_dat
    ) %>% 
    lm(
      mu_ind_change ~ 1 
    , weights = weight
    , data=.
    )

  outline = data.frame(network=nets
                       , p.val=coef(summary(mod))[4]
                       , est=coef(summary(mod))[1]
                       , std.err = coef(summary(mod))[2]
                       , N=nobs(mod)
                       )
  result = rbind(result, outline)
}

result$p.val = round(result$p.val, 4)
result$est = round(result$est, 4)
result$std.err = round(result$std.err, 4)


result

beckertheme =   theme(panel.background=element_rect(fill="white", color="black", size=1.1), 
                      axis.text=element_text(size=rel(1), color="black"), 
                      strip.text=element_text(size=rel(1.1)), 
                      legend.text=element_text(size=rel(1.1)), strip.background=element_blank(),
                      title=element_text(size=rel(1.1)),
                      panel.grid=element_blank(),
                      plot.title=element_text(hjust=0.5))

colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF", solo = "#A9A9A9")





result %>%
  ggplot(aes(x=network, y=est, fill = network)) +
  geom_bar(stat = "identity", position = position_dodge(width = .9)) +
  geom_linerange(
    aes(ymax = est+(1.96*std.err), ymin= est-(1.96*std.err)),
    position = position_dodge(width = 0.9)
  ) + 
  scale_fill_manual(values = colors) + 
  beckertheme +
  theme(aspect.ratio = .75) + 
  theme(axis.text.x=element_text(angle=90)) + 
  labs(x = "Network",
       y= "Mean Ind Error Change") + 
  theme(aspect.ratio = .75) +
  theme(legend.key.size = unit(4, 'mm'))
 
ggsave("Figures/figur3_main_effect_network.png", width = 4.5, height = 3.33, dpi=1000)

result$network
