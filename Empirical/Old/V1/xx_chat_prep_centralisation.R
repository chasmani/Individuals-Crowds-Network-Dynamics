rm(list=ls());gc()
require(DescTools)
require(tidyverse)

#### PREP GURCAY DATA

question_lookup = read.csv("data/question_lookup.csv", stringsAsFactors=F, header=F,fileEncoding="UTF-8-BOM") %>%
  `colnames<-`(c("question","true.values")) %>%
  mutate(
    question=tolower(question)
    ,true.values=round(true.values,2)
  )

chats = read.csv("data/chatlog.csv", stringsAsFactors=F) %>%
  mutate(
    subject.no = as.numeric(sapply(strsplit(Rs,";"), "[", 1))
    , Qs=tolower(Qs)
    , question = unlist(lapply(Qs, FUN=function(x){names(which(sapply(question_lookup$question, grepl, x)))}))
  )


gurc_d <- read.csv("data/gurcay_2015.csv") %>% 
  subset(condition!="C") %>%
  mutate(
    valid = !is.na(est1) & !is.na(est2)
    , pre_influence = est1
    , post_influence = est2
  ) %>% 
  subset(valid) %>% 
  mutate(
    group_number = group
    , true.values = round(true.values, 2)
    , truth = true.values
    , is_central = NA
  ) %>%
  merge(question_lookup, by="true.values") %>%
  mutate(
    task = question
    , trial=group_number
  )

chat_sum_individ = chats %>%
  group_by(subject.no, question) %>%
  summarize(
    count_chat = length(Rs)
    , count_words = sum(nchar(Rs))
  ) %>%
  rowwise() %>%
  subset(subject.no %in% gurc_d$subject.no) %>%
  mutate(
    group_number = unique(gurc_d$group[gurc_d$subject.no==subject.no])
  )



gurc_dat = gurc_d %>%
  ### some chat groups seem to be missing the chat data.
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


discussion_dat = read.csv("data/discussion_data.csv") %>%
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


becker_2017_dat = read.csv("data/becker_2017.csv") %>%
  subset(network == "Centralized") %>%
  mutate(
    pre_influence = response_1
    , post_influence = response_3
    , truth = truth
    , is_central = is_central
    , task = task
    , trial= group_number
    , dataset = "becker 2017"
    , count_chat = NA
    , count_words = NA
  ) %>%
  group_by(task, trial) %>%
  mutate(
    soc_info = mean(pre_influence, na.rm=T)
  )


cols=c("dataset", "task", "trial", "pre_influence","post_influence","truth",
       "is_central","count_chat","count_words", "soc_info")

out_dat = rbind(
  gurc_dat[, cols] %>% as.data.frame
  , discussion_dat[, cols] %>% as.data.frame
  , becker_2017_dat[, cols] %>% as.data.frame
  ) %>%
  subset(!is.na(pre_influence) & !is.na(post_influence)) %>%
  mutate(
    #  mu1 = mean(pre_influence, na.rm=T)
    alpha_back = (post_influence - soc_info)/(pre_influence-soc_info)
    , alpha = (pre_influence - post_influence)/(pre_influence-soc_info)
    
    , stubborn_cent = 1-alpha
    , pre_err = abs(log(pre_influence/truth))
    , post_err = abs(log(post_influence/truth))
    , delta_err = post_err - pre_err
    , improve = ifelse(delta_err<0, 1, 0)
    , not_worse = ifelse(delta_err > 0, 0, 1)
  ) %>%
  group_by(task, trial, dataset) %>%
  mutate(
    mu1 = mean(pre_influence)
    , toward_truth = ifelse((pre_influence < mean(pre_influence) & mu1 <= truth) | (pre_influence > mu1 & mu1 >= truth), "Away","Toward")
  ) %>%
  ungroup

group_dat = out_dat %>%
  group_by(task, trial, dataset) %>%
  summarize(
    truth=unique(truth)
    ## mean
    , mu1 = mean(pre_influence)
    , mu2 = mean(post_influence)
    
    ## error of mean
    , crowd_pre_err = abs(log(mu1/truth))
    , crowd_post_err = abs(log(mu2/truth))
    , mu_crowd_change = crowd_post_err - crowd_pre_err
    , mu_ind_change = mean(delta_err)

    
    
    ## centralization
    , gini_alpha = Gini(stubborn_cent)
    , gini_alpha = ifelse(is.na(gini_alpha), 0, gini_alpha)
    
    , gini_talkativeness = Gini(count_chat)
    , gini_talkativeness_present_only = Gini(count_chat[count_chat>0])
    , gini_words = Gini(count_words)
    , mean_talkativeness = mean(count_chat)
    , mean_talkativeness_present_only = mean(count_chat[count_chat>0])
    , mean_words = mean(count_words)
    , total_talkativeness=sum(count_chat)
    , total_words = sum(count_words)
    , count_in_convo = sum(count_words!=0)
    
    # old version used ifelse(dataset == "becker 2017") - this included a datapoint for each row in ouput_dat instead of summary acrross the group, similiar to not using unique(truth)
    , central_twd_truth = if(any(`dataset` ==  "becker 2017")) toward_truth[is_central == TRUE]=="Toward"
      else toward_truth[!is.na(toward_truth)][which.max(count_chat[!is.na(toward_truth)])]=="Toward"
    
    
    # group improvement
    , mu_ind_improv = sum(improve)/n()
    , mu_ind_not_worse = sum(not_worse)/n()
    , crowd_improve = ifelse(mu_crowd_change < 0, 1, 0)
    , crowd_not_worse = ifelse(mu_crowd_change > 0, 0, 1)
    
    )
    



group_dat = subset(dat_group, is.finite(mu_ind_change))


for (var in unique(group_dat$dataset)) {
  
  # plot the mean crowd change vs the mean individual change in error for each datatset
  plot_dat = subset(group_dat, dataset == var) %>%
    group_by(trial)
  print(ggplot(data = plot_dat
               , aes(gini_talkativeness_present_only, mu_ind_change)) + 
          geom_point() + 
          ggtitle(var) +
          geom_hline(yintercept=0, linetype="dashed", color="#333333") + 
          geom_vline(xintercept=0, linetype="dashed", color="#333333"))
}

group_dat %>%
  subset(dataset == "becker 2017") %>%
  group_by(task, trial) %>%
  summarise(
    individual_improvement = mean(mu_ind_change)
    , group_imrpovement = mean(crowd_improv)
  ) %>%
  ggplot(
    aes(mu_ind_change, gini_talkativeness)) + 
        geom_point() + 
        ggtitle('centralisation vs indv change') +
        geom_hline(yintercept=0, linetype="dashed", color="#333333") + 
  facet_grid(~dataset)

propToward = function(x, truth) {
  prop_above = mean(x>mean(x))
  ifelse(truth>mean(x), prop_above, 1-prop_above)
}
  

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


library(reshape2)

#######central twards truth plots#########

sum = group_dat %>%
  subset(dataset == "becker 2017") %>%
  mutate(
    central_twd_truth = ifelse(central_twd_truth, "Toward","Away")
  ) %>% 
  group_by(central_twd_truth) %>%
  summarise(
    individual_improvement = mean(mu_ind_not_worse)
    , group_imrpovement = mean(crowd_not_worse)
  )

sum2 = melt(data = sum, id.vars = "central_twd_truth")

sum2 %>%
  ggplot(aes(x = central_twd_truth, y = value, colour = variable)) + 
  geom_point() +
  labs(x="Central Node Toward Truth", y="Mean % Not Worse") +
  nice_theme()


sum %>%
  ggplot(aes(x=central_twd_truth, y=group_imrpovement
  )) +
  geom_point() + 
  labs(x="Central Node Toward Truth", y="Mean Ind% Improve")



group_dat %>%
  mutate(
    central_twd_truth = ifelse(central_twd_truth, "Toward","Away")
  ) %>% 
  group_by(central_twd_truth) %>%
  summarise(
    individual_improvement = mean(mu_ind_change)
    , group_imrpovement = mean(crowd_improve)
  ) %>%
  ggplot(aes(x=central_twd_truth, y=individual_improvement
  )) +
  geom_point() + 
  # geom_errorbar(aes(ymin=lower, ymax=upper), width=0, position=position_dodge(0.5)) +
  # geom_hline(yintercept=0.5, linetype="dashed") +
  # scale_y_continuous(labels=pct_labels, lim=c(0.15,0.85))+
  labs(x="Central Node Toward Truth", y="Mean Ind% Improve") +
  nice_theme()


group_dat %>%
  ggplot(
    aes(x = central_twd_truth, y = mu_ind_improv, fill = central_twd_truth)) +
  geom_violin(aes(color = central_twd_truth)) + #,position = position_nudge(x = .1, y = 0), adjust = 1.5, trim = TRUE, alpha = .5) #+
  # geom_point(aes(x = crowd_quartile, y = med_ind_change, colour = network),position = position_jitter(width = .05), size = 1, shape = 20) + 
  # geom_boxplot(aes(x = crowd_quartile, y = med_ind_change, fill = network),outlier.shape = NA, alpha = .5, width = .1, colour = "black") +
  # # scale_colour_brewer(palette = "Dark2") +
  # # scale_fill_brewer(palette = "Dark2") +
  facet_grid(.~dataset) +
  labs(x="Central Node Toward Truth", y="Mean Ind% Improve") +
  nice_theme()
