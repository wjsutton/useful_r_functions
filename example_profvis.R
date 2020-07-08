# Creates a line by line time profile for R script
# useful for finding bottlenecks and sections of code 
# that could be sped up
# depends on "profvis" package

#install.packages("profvis")
library(profvis)

# Example
profvis({
  source("examples/horizontal_bar_chart_plot.R")
})
  
