## SET WORKING DIRECTORY TO SOURCE LOCATION
library(tidyverse)

s1a = read.csv("indS1dates1.csv") %>%
  select(ID, question, Correct, E1, E2, C1, group) %>%
  mutate(study="1a")

s1b = read.csv("indS1dates2.csv") %>%
  select(ID, question, Correct, E1, E2, C1, group) %>%
  mutate(study="1b")

s1c = read.csv("indS1pops1.csv") %>%
  select(ID, question, Correct, E1, E2, C1, group) %>%
  mutate(study="1c")

s1d = read.csv("indS1pops2.csv") %>%
  select(ID, question, Correct, E1, E2, C1, group) %>%
  mutate(study="1d")


s2a = read.csv("IndS2dates.csv") %>%
  select(ID, question, Correct, E1, E2, C1, group) %>%
  mutate(study="2a")

s2b = read.csv("IndS2dist.csv") %>%
  select(ID, question, Correct, E1, E2, C1, group) %>%
  mutate(study="2b")

s2c = read.csv("IndS2Stocks.csv") %>%
  select(ID, question, Correct, E1, E2, C1, group) %>%
  mutate(study="2c")


jb1 = read.csv("Jb1.csv") %>%
  select(ID, question, Correct, E1, E2, C1, group) %>%
  mutate(study="jba")

jb2 = read.csv("Jb2.csv") %>%
  select(ID, question, Correct, E1, E2, C1, group) %>%
  mutate(study="jbb")

jb3 = read.csv("Jb3.csv") %>%
  select(ID, question, Correct, E1, E2, C1, group) %>%
  mutate(study="jbc")

all_silver = rbind(
    s1a, s1b, s1c, s1d
  , s2a, s2b, s2c
  , jb1, jb2, jb3
)

write.csv(all_silver, "../silver_et_al.csv", row.names=F)
