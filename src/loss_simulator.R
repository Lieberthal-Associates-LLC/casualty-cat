# Given simulation parameters and policy matrix, run simulation
if(!require("EnvStats")) install.packages("EnvStats")
import(EnvStats)
import(R.oo)
import(stats)
import(utils)

sampleSeverity <- function(numSamples = 1, mu = 1, sigma = 0.5, aPar = 2, lambdaPar = 5, p = 0.3) {
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
                                              meanEventPoisson = 0.5)
                            ) {
  #simulates ground-up loss for 1 year
  activityNames = parameters$activityNames
  activityProbs = parameters$activityProbs
  numEvents = sample_num_events(parameters$zeroEventProb, parameters$meanEventPoisson)
  events = sampleEvents(numEvents, activityNames, activityProbs)
  expAmt = expMat[2]
  compExp = expMat[3:length(expMat)]
  print(compExp)
  #X_ca = S * Exp_ca * affects_a
  totalLosses = compExp * 0
  for(event in events) {
    cat("Event:\n")
    print(event)
    cat("Loss from event:\n")
    eventLosses = (t(t(compExp) * event$affectsActivities))
    print(eventLosses)
    totalLosses = totalLosses + eventLosses
  }
  return(totalLosses)
}
# return dataframe of simulation losses








