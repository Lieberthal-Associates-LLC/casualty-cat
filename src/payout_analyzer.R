# Interpret and visualize loss simulation results
import(stats)

calculate_loss_intervals <- function(losses, parameters = list()) {
  lossesPerYear = unlist(lapply(losses, sum))
  cat("\n90% confidence confidence interval for losses:", 
      quantile(lossesPerYear, 0.05),
      quantile(lossesPerYear, 0.95))
}

calculate_payout_intervals <- function(payouts, parameters = list()) {
  payoutsPerYear = unlist(lapply(payouts, sum))
  cat("\n90% confidence confidence interval for payouts:", 
      quantile(payoutsPerYear, 0.05),
      quantile(payoutsPerYear, 0.95),
      "\n")
}
# print list of loss confidence intervals by policy

export('visualize_losses')
visualize_losses <- function(losses, parameters) {}
# display and save visuals relating to simulation results

export('calculate_alae')
calculate_alae <- function(losses, parameters) {}
# return ALAE list

calculate_payout_pct <- function(payouts, events, losses) {
  totalPayout = 0.
  totalSeverity = 0.
  totalLoss = 0.
  numRuns = length(events)
  if(numRuns == 0) {return()}
  for(runIdx in 1:numRuns) {
    totalPayout = totalPayout + sum(payouts[[runIdx]])
    totalLoss = totalLoss + sum(losses[[runIdx]])
    numEvents = length(events[[runIdx]])
    if(numEvents > 0) {
      for(eventIdx in 1:numEvents) {
        totalSeverity = totalSeverity + sum(events[[runIdx]][[eventIdx]]$severity)
      }
    }
  }
  cat("\nTotal Event Severity:",
      totalSeverity,
      "\nTotal Loss:",
      totalLoss,
      "\nTotal Payout:",
      totalPayout,
      "\n"
      )
  if(totalSeverity != 0) {
    cat("\n\nFraction of Severity Paid Out:",
        totalPayout / totalSeverity,
        "\n")
  }
  if(totalLoss != 0) {
    cat("\nFraction of Loss Paid Out:",
        totalPayout / totalLoss,
        "\n")
  }
}

export('analyze')
analyze <- function(payouts, events, losses) {
  # TODO - Add in a calculation of the losses
  cat("\n\n========================================================================\n\n")
  calculate_loss_intervals(losses)
  calculate_payout_intervals(payouts)
  calculate_payout_pct(payouts, events, losses)
}