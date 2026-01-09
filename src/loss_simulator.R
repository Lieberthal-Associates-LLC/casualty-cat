# Given simulation parameters and policy matrix, run simulation
if(!require("EnvStats")) install.packages("EnvStats")
import(EnvStats)
import(R.oo)
import(stats)
import(utils)

sampleSeverity <- function(numSamples = 1, mu = 15, sigma = 2, aPar = 2, lambdaPar = 1e5, p = 0.3) {
  # with probability p, samples X ~ LogNormal(mu, sigma)
  # with probability 1-p, samples Y ~ Pareto(aPar, lambdaPar)
  X = rlnorm(numSamples, meanlog=mu, sdlog=sigma)
  Y = rpareto(numSamples, location = lambdaPar, shape = aPar)
  U = runif(numSamples)
  severity = ifelse(U < p, yes = X, no = Y)
  return(severity)
}
sampleActivities <- function(numSamples = 1, activityNames, activityProbs) {
  numActivities = length(activityNames)
  if(length(activityNames) != length(activityProbs)) {
    throw("Length of actvityNames (", length(activityNames), ") does not match length of activityProbs (", length(activityProbs), ")")
  }
  U = runif(numActivities * numSamples)
  dim(U)<- c(numActivities, numSamples)
  affectsActivities = U < activityProbs
  dimnames(affectsActivities)[[1]]<- activityNames
  return(affectsActivities)
}

sampleEvents <- function(numSamples, activityNames, activityProbs) {
  severities = sampleSeverity(numSamples)
  affectsActivities = sampleActivities(numSamples, activityNames, activityProbs)
  events = list()
  for(colInd in 1:length(severities)) {
    severity = severities[colInd]
    activities = affectsActivities[,colInd]
    event = list(severity = severity, affectsActivities = activities)
    events = c(events, list(event))
  }
  return(events)
  # returns list of events
}

sample_num_events <- function(zeroProb, meanPoisson) {
  if(runif(1) < zeroProb) {return(0.0)}
  else {return(rpois(1, meanPoisson))}
}

export("simulate_year")
simulate_year <- function(expMat, parameters = list(
                                              activityNames = c(11, 21, 22, 23, 31, 42, 44, 48, 51, 52, 53, 54, 55, 56, 61, 62, 71, 72, 81, 92),
                                              activityProbs = rep(1/5, 20),
                                              zeroEventProb = 0.7,
                                              meanEventPoisson = 2.0,
                                              logShockSd = 0.05)
                            ) {
  #simulates ground-up loss for 1 year
  activityNames = parameters$activityNames
  activityProbs = parameters$activityProbs
  expAmt = expMat[2]
  numCompanies = dim(expMat)[1]
  compExp = expMat[3:length(expMat)]
  
  numEvents = sample_num_events(parameters$zeroEventProb, parameters$meanEventPoisson)
  losses = array(0, dim = c(numCompanies, numEvents))
  rownames(losses) = rownames(compExp)
  if(numEvents == 0) {
    cat("No catastrophe events\n")
    return(losses)
  }
  cat("Generated", numEvents, "events\n\n")
  colnames(losses) = paste("Event", 1:numEvents)
  events = sampleEvents(numEvents, activityNames, activityProbs)
  #X_ca = S * Exp_ca * affects_a
  for(eventIdx in 1:numEvents) {
    cat("Event", eventIdx, "\n")
    event = events[[eventIdx]]
    print(event)
    cat("Losses (by activity):\n")
    eventLoss = event$severity * t(t(compExp) * event$affectsActivities)
    eventLoss = eventLoss * rlnorm(eventLoss, meanlog = 0, sdlog = parameters$logShockSd)
    print(eventLoss)
    
    eventLoss = apply(eventLoss, 1, sum)
    cat("\nLosses (aggregated over activities):\n")
    print(eventLoss)
    losses[,eventIdx] = eventLoss
  }
  cat("\n\nAll losses:\n")
  print(losses)
  cat("\n\n------------------------------------------------------------------------\n\n")
  return(losses)
}
# return dataframe of simulation losses





