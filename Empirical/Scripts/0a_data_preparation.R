rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)

data_path = "../data/"

# load datasets

lorenz_2011 = read.csv(paste0(data_path, "lorenz_2011.csv")) %>%
  mutate(
    pre_influence = E1
    , post_influence = E5
    , truth = Truth
    , is_central = NA
    , network = fct_recode(Information_Condition, "decentralized" = "full", "solo" = "no", "decentralized"="aggregated")
    , trial= paste0(Session_Date, Information_Condition)
    , task = Question
    , dataset = "lorenz 2011"
    , group_id = paste0(network, task, trial)
    , confidence = C1
    , subject = paste0(Subject, Session_Date)
  )

becker_2017 = read.csv(paste0(data_path, "becker_2017.csv")) %>%
  mutate(
    pre_influence = response_1
    , post_influence = response_3
    , truth = truth
    , is_central = is_central
    , network = fct_recode(network, "centralized" = "Centralized", "decentralized" = "Decentralized", "solo" = "Solo")
    , task = task
    , trial= group_number
    , dataset = "becker 2017"
    , count_chat = NA
    , count_words = NA
    , group_id = paste0(network, task, trial)
    , subject=subject_id
    , confidence=NA
    
  ) %>%
  group_by(task, trial) %>%
  mutate(
    soc_info = mean(pre_influence, na.rm=T)
  )

# load gurcay chat data and then the gurcay data

question_lookup = read.csv(paste0(data_path, "question_lookup.csv"), stringsAsFactors=F, header=F,fileEncoding="UTF-8-BOM") %>%
  `colnames<-`(c("question","true.values")) %>%
  mutate(
    question=tolower(question)
    ,true.values=round(true.values,2)
  )

gurc_chats = read.csv(paste0(data_path, "chatlog.csv"), stringsAsFactors=F) %>%
  mutate(
    subject.no = as.numeric(sapply(strsplit(Rs,";"), "[", 1))
    , Qs=tolower(Qs)
    , question = unlist(lapply(Qs, FUN=function(x){names(which(sapply(question_lookup$question, grepl, x)))}))
  )

gurcay_2015 =  read.csv(paste0(data_path, "gurcay_2015.csv")) %>%
  mutate(
    pre_influence = est1
    , post_influence = est2
    , truth = round(true.values, 2)
    , true.values = round(true.values, 2)
    , is_central = NA
    , network = fct_recode(condition, "discussion" = "G", "solo" = "C", "discussion"="I")
    , task = question.no
    , group_number= group
    , dataset = "gurcay 2015"
    , confidence=conf1
    , subject=subject.no
  ) %>%
  merge(question_lookup, by="true.values") %>%
  mutate(
    task = question
    , trial=group_number
    , group_id = paste0(network, task, trial)
  )

if(!file.exists("../data/becker_2019.csv")){
  
  becker_2019 = read.csv(url("https://raw.githubusercontent.com/joshua-a-becker/wisdom-of-partisan-crowds/master/Becker%20Centola%20Porter%20-%20Wisdom%20of%20Partisan%20Crowds%20-%20Supplementary%20Dataset.csv")) %>%
    mutate(
      pre_influence=response_1
      , post_influence=response_3
      , truth = truth
      , is_central = NA
      , network= fct_recode(network, "decentralized" = "Social", "solo" = "Control") 
      , task=q
      , trial=paste0(set,pair_id,network,experiment,party)
      , dataset="becker 2019"
      , group_id = paste0(network, task, trial)
      , subject=paste0(user_id, trial)
      , confidence=NA
    ) 
  write.csv(becker_2019, "../data/becker_2019.csv")
  } else {
  becker_2019 = read.csv("../data/becker_2019.csv", stringsAsFactors=F)
}

silver_2021 = read.csv("../data/silver_et_al.csv") %>%
  mutate(
      E1 = gsub(",","",E1)
    , E2 = gsub(",","",E2)
    , pre_influence=as.numeric(E1)
    , post_influence=as.numeric(E2)
    , truth = as.numeric(Correct)
    , is_central = NA
    , network= "decentralized"
    , task=question
    , trial=paste0(question, group, study)
    , dataset="silver 2021"
    , group_id = paste0(question, group, study)
    , confidence = C1
    , subject = ID
  ) 

if(!file.exists("../data/becker_2020.csv")){
  becker_2020 = read.csv("https://raw.githubusercontent.com/joshua-a-becker/emergent-network-structure/master/Replication%20Data/discussion_data.csv") %>%
    mutate (
      pre_influence = initial
      , post_influence = final
      , is_central = NA
      , network = "discussion"
      , task=question
      , trial=trial
      , dataset="becker 2020"
      , group_id = trial
      , confidence=NA
      , subject=NA
    )
  write.csv(becker_2020, "../data/becker_2020.csv")
} else {
  becker_2020 = read.csv("../data/becker_2020.csv", stringsAsFactors=F)
}

