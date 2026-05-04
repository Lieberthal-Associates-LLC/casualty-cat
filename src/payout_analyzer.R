# Interpret and visualize loss simulation results
import(stats)

calculate_loss_intervals <- function(losses, parameters) {
  lossesPerYear = unlist(lapply(losses, sum))
  alpha = (1 - parameters$confidenceLevel) / 2
  header = paste0("\n", round(parameters$confidenceLevel * 100), "% confidence interval for losses:")
  cat(header,
      quantile(lossesPerYear, alpha),
      quantile(lossesPerYear, 1 - alpha))
}

calculate_payout_intervals <- function(payouts, parameters) {
  payoutsPerYear = unlist(lapply(payouts, sum))
  alpha = (1 - parameters$confidenceLevel) / 2
  header = paste0("\n", round(parameters$confidenceLevel * 100), "% confidence interval for payouts:")
  cat(header,
      quantile(payoutsPerYear, alpha),
      quantile(payoutsPerYear, 1 - alpha),
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
analyze <- function(payouts, events, losses, parameters) {
  # TODO - Add in a calculation of the losses
  cat("\n\n========================================================================\n\n")
  calculate_loss_intervals(losses, parameters)
  calculate_payout_intervals(payouts, parameters)
  calculate_payout_pct(payouts, events, losses)
}