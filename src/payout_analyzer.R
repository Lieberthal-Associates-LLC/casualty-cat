# Interpret and visualize loss simulation results
import(stats)

calculate_loss_intervals <- function(payouts, parameters = list()) {
  payoutsPerYear = rep(0, length(payouts))
  for(year in 1:length(payouts)) {
    payoutsPerYear[[year]] = sum(payouts[[year]])
  }
  cat("90% confidence confidence interval for payouts:", 
      quantile(payoutsPerYear, 0.05),
      quantile(payoutsPerYear, 0.95))
}
# print list of loss confidence intervals by policy

export('visualize_losses')
visualize_losses <- function(losses, parameters) {}
# display and save visuals relating to simulation results

export('calculate_alae')
calculate_alae <- function(losses, parameters) {}
# return ALAE list

calculate_payout_pct <- function(payouts, events) {
  totalPayout = 0.
  totalSeverity = 0.
  numRuns = length(events)
  if(numRuns == 0) {return()}
  for(runIdx in 1:numRuns) {
    totalSeverity = totalSeverity + sum(events[[runIdx]]$severity)
    totalPayout = totalPayout + sum(payouts[[runIdx]])
    numEvents = length(events[[runIdx]])
    if(numEvents > 0) {
      for(eventIdx in 1:numEvents) {
        totalSeverity = totalSeverity + sum(events[[runIdx]][[eventIdx]]$severity)
      }
    }
  }
  cat("\n\nTotal Payout:",
      totalPayout,
      "\nTotal Event Severity:",
      totalSeverity
      )
  if(totalSeverity != 0) {
    cat("\nFraction Paid Out:",
        totalPayout / totalSeverity)
  }
}

export('analyze')
analyze <- function(payouts, events, losses) {
  calculate_loss_intervals(payouts)
  calculate_payout_pct(payouts, events)
}