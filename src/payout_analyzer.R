# Interpret and visualize loss simulation results
import(stats)

export('calculate_loss_intervals')
calculate_loss_intervals <- function(payouts, parameters = list()) {
  payoutsPerYear = rep(0, length(payouts))
  for(year in 1:length(payouts)) {
    payoutsPerYear[[year]] = sum(payouts[[year]])
  }
  cat("90% confidence confidence interval for payouts:", 
      quantile(payoutsPerYear, 0.05),
      quantile(payoutsPerYear, 0.95))
}
# return list of loss confidence intervals by policy

export('visualize_losses')
visualize_losses <- function(losses, parameters) {}
# display and save visuals relating to simulation results

export('calculate_alae')
calculate_alae <- function(losses, parameters) {}
# return ALAE list