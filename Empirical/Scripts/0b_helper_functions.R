tukey_out <- function(x, k = 2.5, na.rm = TRUE) {
  quar <- quantile(x, probs = c(0.25, 0.75), na.rm = na.rm)
  iqr <- diff(quar)
  
  !((quar[1] - k * iqr <= x) & (x <= quar[2] + k * iqr))
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


propToward = function(x, truth) {
  prop_above = mean(x>mean(x))
  ifelse(truth>mean(x), prop_above, 1-prop_above)
}



summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE, boot.trials=1) {
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- plyr::ddply(data, groupvars, .drop=.drop,
                       .fun = function(xx, col) {
                         c(N    = length2(xx[[col]], na.rm=na.rm),
                           mean = mean   (xx[[col]], na.rm=na.rm),
                           sd   = sd     (xx[[col]], na.rm=na.rm),
                           bootse = mybootsd(xx[[col]], boot.trials)
                         )
                       },
                       measurevar
  )
  
  # Rename the "mean" column    
  datac <- plyr::rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  datac$bootci = datac$bootse * ciMult
  
  return(datac)
}

mybootsd = function(data, boot.trials=1000, samplesize=-1) {
  if(samplesize<0) { samplesize = length(data) }
  resamples <- lapply(1:boot.trials, function(i) sample(data, size=samplesize, replace=T))
  sd(sapply(resamples, FUN=function(x){mean(x, na.rm=T)}))
}
