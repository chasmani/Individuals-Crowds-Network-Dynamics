rm(list=ls());gc()
library(ggplot2)
library(dplyr)
library(reshape2)
library(tidyverse,warn.conflicts = F, quietly = T)
library(readxl,warn.conflicts = F, quietly = T)
library(httr,warn.conflicts = F, quietly = T)

data_path = "data/"

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
    )
  

navajas_2018 =  read.csv(paste0(data_path, "navajas_2018.csv")) %>%
  mutate(
    pre_influence = pre_influence
    , post_influence = post_influence
    , truth = truth
    , is_central = NA
    , network = "discussion"
    , task = task
    , trial= trial
    , dataset = "navajas 2018"
    )


# TODO include chat data
gurcay_2015 =  read.csv(paste0(data_path, "gurcay_2015.csv")) %>%
  mutate(
    pre_influence = est1
    , post_influence = est2
    , truth = round(true.values, 2)
    , is_central = NA
    , network = fct_recode(condition, "discussion" = "G", "solo" = "C", "discussion"="I")
    , task = question.no
    , trial= group
    , dataset = "gurcay 2015"
    )

if(!file.exists("data/becker_2019.csv")){
  
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
    ) 
  write.csv(becker_2019, "data/becker_2019.csv")
} else {
  becker_2019 = read.csv("data/becker_2019.csv", stringsAsFactors=F)
}

delphi_data =  read.csv(paste0(data_path, "delphi_data.csv")) %>%
  mutate(
    pre_influence = response_1
    , post_influence = response_5
    , truth = truth
    , is_central = NA
    , network = "decentralized"
    , task = question
    , trial= trial
    , dataset = "delphi data"
  )


# TODO include chat data
discussion_data =  read.csv(paste0(data_path, "discussion_data.csv")) %>%
  mutate(
    pre_influence = initial
    , post_influence = final
    , truth = truth
    , is_central = NA
    , network = "discussion"
    , task = question
    , trial= trial
    , dataset = "discussion data"
  )

almaatouq_2020 =  read.csv(paste0(data_path, "almaatouq_2020.csv")) %>%
  mutate(
    pre_influence = independent_guess
    , post_influence = revised_guess
    , truth = correct_answer
    , is_central = NA
    , network = fct_recode(
      condition
      , "centralized_almaa" = "dynamic_no_feedback"
      , "centralized_almaa" = "dynamic_full_feedback"
      , "centralized_almaa" = "dynamic_self_feedback"
      , "centralized_almaa" = "dynamic"
      , "solo_almaa" = "solo_feedback"
      , "solo_almaa" = "solo_no_feedback"
      , "centralized_almaa" = "static")
    , task = round_index
    , trial= paste0(game_id, round_index)
    , dataset = "almaatouq 2020"
  )





