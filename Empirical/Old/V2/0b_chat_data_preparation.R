rm(list=ls());gc()

source("scripts/0a_data_preparation.R")


becker17_d = subset(becker_2017, network == "centralized")

chat_sum_individ = gurc_chats %>%
  group_by(subject.no, question) %>%
  summarize(
    count_chat = length(Rs)
    , count_words = sum(nchar(Rs))
  ) %>%
  rowwise() %>%
  subset(subject.no %in% gurcay_2015$subject.no) %>%
  mutate(
    group_number = unique(gurcay_2015$group[gurcay_2015$subject.no==subject.no])
  )

gurc_d = subset(gurcay_2015, condition!="C") %>%
  merge(
    .  
    , chat_sum_individ
    , by=c("subject.no","question")
    , all.x=T
  ) %>% mutate(
    dataset="gurcay 2015"
  ) %>%
  group_by(task, trial) %>%
  mutate(
    soc_info = mean(pre_influence)
  ) %>%
  mutate(count_chat = ifelse(is.na(count_chat), 0, count_chat)
         , count_words = ifelse(is.na(count_chat), 0, count_words)
         
         ### ensure that actual missing data is encoded as NA
         , count_chat = ifelse(!group %in% chat_sum_individ$group_number, NA, count_chat)
         , count_words = ifelse(!group %in% chat_sum_individ$group_number, NA, count_words)
  )



discussion_chat = read.csv("data/chat_data.csv", stringsAsFactors=F) %>%
  group_by(trial, playerId) %>%
  summarize(
    count_chat = sum(!is.na(text))
    , count_words = sum(nchar(text))
    , count_words = ifelse(is.na(count_words), 0, count_words)
  )


discussion_d = read.csv("data/discussion_data.csv") %>%
  mutate(
    task=question
    , pre_influence = initial
    , post_influence = final
    , dataset="discussion data"
    , is_central = NA
    , trial = trial
    , truth = truth
  ) %>%
  merge(discussion_chat, by=c("playerId","trial")) %>%
  group_by(task, trial) %>%
  mutate(
    soc_info = mean(pre_influence, na.rm=T)
  )