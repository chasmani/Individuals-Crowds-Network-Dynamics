result = data.frame()
for(nets in unique(group_d$network)) { 
  for(this_improv in c(T,F)) {
    
    mod = group_d %>%
      subset(network == nets & crowd_improvement==this_improv) %>% 
      mutate(
        count_dat=length(unique(dataset))
      )%>%
      group_by(dataset) %>%
      mutate(
        weight = (1 / length(pct_not_worse))/count_dat
      ) %>% 
      lm(
        pct_not_worse ~ 1 
        , weights = weight
        , data=.
      )
    
    outline = data.frame(network=nets
                         , crowd_improvement = this_improv
                         , p.val=coef(summary(mod))[4]
                         , est=coef(summary(mod))[1]
                         , std.err = coef(summary(mod))[2]
                         , N = nobs(mod)
    )
    result = rbind(result, outline)
  }}



result$p.val = round(result$p.val, 4)
result$est = round(result$est, 4)
result$std.err = round(result$std.err, 4)

result %>% format(scientific=F)

result = data.table::data.table(result)
result[,y_min := min(est) * 1.01, by = crowd_improvement]
result[,y_max := 0 + abs(min(est)* 1.01), by = crowd_improvement]

beckertheme =   theme(panel.background=element_rect(fill="white", color="black", size=1.1), 
                      axis.text=element_text(size=rel(1), color="black"), 
                      strip.text=element_text(size=rel(1.1)), 
                      legend.text=element_text(size=rel(1.1)), strip.background=element_blank(),
                      title=element_text(size=rel(1.1)),
                      panel.grid=element_blank(),
                      plot.title=element_text(hjust=0.5))
colors = c(centralized = "#3C5488FF", decentralized = "#4DBBD5FF", discussion = "#00A087FF")
shapes = c(centralized = 19, decentralized = 19, discussion = 19)

result %>%
  subset(network != "solo") %>%
  ggplot(aes(x = crowd_improvement, y = est, color = network)) +
  geom_point(size = 2.5, position = position_dodge(0.1), alpha = 0.75) + 
  geom_linerange(
    aes(ymax = est+(1.96*std.err), ymin= est-(1.96*std.err)),
    position = position_dodge(width = 0.1)
  ) + 
  geom_hline(yintercept=0, linetype="dashed", color="#808080") +
  scale_color_manual(values = colors) + 
  beckertheme + 
  geom_blank(aes(y = y_min)) +
  geom_blank(aes(y = y_max)) +
  theme(aspect.ratio = 1) +
  labs(x="Crowd Improvement",
       y="% Ind. Not Worse")

ggsave("../Figures/New Figures/Figure 4/NOT_WORSE_X_NETWORK_crowd_outcome.png", width = 4, height = 3, dpi=1000)
