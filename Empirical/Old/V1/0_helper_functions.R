

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