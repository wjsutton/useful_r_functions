# Adds a progress bar to script, with eta
# depends on "progress" package

#install.packages("progress")
library(progress)

pb <- progress_bar$new(format = "  working [:bar] :percent eta: :eta",
                       total = 100, 
                       clear = FALSE, 
                       width= 60)

f <- function() {
  pb$tick(0)
  Sys.sleep(3)
  for (i in 1:100) {
    pb$tick()
    Sys.sleep(1 / 100)
  }
}
f()
