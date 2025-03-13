


#### ON CONFIDENCE #####

glm(crowd_improvement ~ calibration, group_d, family="binomial")%>%
  summary



group_d %>%
  # subset(dataset=="silver 2021") %>%
  subset(!is.na(calibration)) %>%
  mutate(
    cal = round(calibration, 1)
  ) %>% ungroup %>%
  group_by(cal, dataset) %>%
  summarize(
    y = mean(crowd_improvement)
  )%>%
  ggplot(aes(x=cal, y=y, color=dataset)) +
  geom_point() +
  nice_theme()



group_d %>%
  # subset(dataset=="silver 2021") %>%
  subset(!is.na(calibration)) %>%
  mutate(
    cal = round(calibration, 1)
    , task_cal = round(task_calibration, 1)
  ) %>%
  group_by(dataset) %>%
  summarize(
    , sd=sd(cal, na.rm=T)
    , cal=mean(cal)
    , task_cal = mean(task_cal)
  )
