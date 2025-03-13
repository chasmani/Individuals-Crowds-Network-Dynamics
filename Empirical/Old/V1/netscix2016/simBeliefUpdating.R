rm(list = ls()) # Remove all the objects we created so far

require(igraph)
require(mvtnorm)
require(dplyr)
require(ggplot2)

master_output = data.frame()

truth = 0
time = 1
for (t in 1:time) {
  
  g=sample_pa(n=50, power=2, m=2, directed=F)
  
  #g = degree.sequence.game(rep(4, 50), method = "simple.no.multiple")
  #plot(g)
  
  V(g)$initial_signal = rnorm(vcount(g), truth, 1)
  V(g)$signals <- sapply(1:vcount(g),function(i)list(rep(NA, vcount(g) - 1)))
  
  for (i in (1:vcount(g))) {
    V(g)$signals[[i]][1] = V(g)$initial_signal[i][1]
  }

  V(g)$belief = sapply(1:vcount(g), function(i)mean(V(g)$signals[[i]], na.rm = T))
  # output = data.frame(
  #   time = t
  #   , round = 0
  #   , mean_belief = mean(V(g)$belief, na.rm = T)
  #   , mean_ind_err = mean(abs(V(g)$belief - truth))
  #   , crowd_error = abs(mean(V(g)$belief, na.rm = T) - truth)
  # )
  
  output = data.frame()
  
  # randomize list of edges to walk through
  list_edges = sample(E(g))
  for (i in 1:length(list_edges)) {
    #e = ends(g, E(g)[i]) # if you don't want random edge order
    e = ends(g, list_edges[i])
    tail_vertex = e[,1]
    head_vertex = e[,2]
    
    tail_signals = V(g)$signals[[tail_vertex]][!is.na(V(g)$signals[[tail_vertex]])]
    head_signals = V(g)$signals[[head_vertex]][!is.na(V(g)$signals[[head_vertex]])]
    
    tail_unique = tail_signals[!tail_signals %in% head_signals]
    head_unique = head_signals[!head_signals %in% tail_signals]
    
    tail_signal = V(g)$signals[[tail_vertex]][1]
    tail_rand_signal = sample(tail_signals, 1)
    tail_uniq_signal = tail_unique[1]
    
    head_signal = V(g)$signals[[head_vertex]][1]
    head_rand_signal = sample(head_signals, 1)
    head_uniq_signal = head_unique[1]
    
    i_tail = vcount(g) - sum(is.na(V(g)$signals[[tail_vertex]]))
    V(g)$signals[[tail_vertex]][i_tail] = head_uniq_signal
    i_head = vcount(g) - sum(is.na(V(g)$signals[[head_vertex]]))
    V(g)$signals[[head_vertex]][i_head] = tail_uniq_signal
    
    V(g)$belief = sapply(1:vcount(g), function(i)mean(V(g)$signals[[i]], na.rm = T))
    
    output_row = data.frame(
      time = t
      , round = i
      , mean_belief = mean(V(g)$belief, na.rm = T)
      , mean_ind_err = mean(abs(V(g)$belief - truth))
      , crowd_error = abs(mean(V(g)$belief, na.rm = T) - truth)
    )
  
    output = rbind(output, output_row)
  
  }
  
  print(t)
  master_output = rbind(master_output, output)
  
}


output %>%
  ggplot(
    aes(x=round, y=crowd_error)) + geom_point()

output %>%
  ggplot(
    aes(x=round, y=mean_ind_err)) + geom_point()

master_output

mu_output = master_output %>%
  group_by(round) %>%
  summarise(
    mu_belief = mean(mean_belief)
    , mu_ind_err = mean(mean_ind_err)
    , mu_crowd = mean(crowd_error)
  )

### convenient for plotting
nice_theme = function() {
  theme_test() +
    theme(strip.background=element_blank()
          , strip.text=element_text(face="bold", size=rel(1.1))
          , axis.title = element_text(face="bold", size=rel(1.3))
          , plot.title = element_text(face="bold", size=rel(1.5))
          , plot.subtitle = element_text(face = "italic", size=rel(1.2))
    )
}


mu_output %>%
  ggplot(
    aes(x=round, y=mu_crowd)) + geom_point()


mu_output %>%
  ggplot(
    aes(x=round, y=mu_ind_err)) + geom_point()

master_output %>%
  ggplot(
    aes(x=round, y=crowd_error, color=time)) + geom_point() + 
  geom_hline(yintercept = 0)

master_output %>%
  ggplot(
    aes(x=round, y=crowd_error)) + stat_summary(fun.y="mean", geom="point")+
  geom_hline(yintercept = 0) +
  labs(x="Round", 
       y="Mean crowd error") +
  nice_theme()

master_output %>%
  ggplot(
    aes(x=round, y=mean_ind_err, color=time)) + geom_point() + 
  geom_hline(yintercept = 0)

master_output %>%
  ggplot(
    aes(x=round, y=mean_ind_err)) + stat_summary(fun.y="mean", geom="point") + 
    geom_hline(yintercept = 0) +
  labs(x="Round", 
       y="Mean individual error") +
  nice_theme()



