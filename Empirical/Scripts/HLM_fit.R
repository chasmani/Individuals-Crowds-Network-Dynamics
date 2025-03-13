
mod = lmer(pct_improve_revised ~ network*crowd_improvement + (crowd_improvement | dataset), data = group_d)

summary(mod)

myfit = fitted(mod)
myy=group_d$pct_improve_revised[!is.na(group_d$pct_improve_revised)]
length(myfit)
length(myy)

myd = subset(group_d, !is.na(pct_improve_revised))

myd$fit = myfit

myd %>% 
  group_by(network, crowd_improvement, dataset) %>%
  summarize(
    fit=mean(fit)
    , pct_improve_revised = mean(pct_improve_revised)
  ) %>%
  group_by(network, crowd_improvement) %>%
  summarize(
    fit=mean(fit)
    , pct_improve_revised = mean(pct_improve_revised)
  )

summary(mod)