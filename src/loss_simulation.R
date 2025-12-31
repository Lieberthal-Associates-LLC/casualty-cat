# Given simulation parameters and policy matrix, run simulation
if(!require("EnvStats")) install.packages("EnvStats")
library(EnvStats)
library(R.oo)

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

export('simulate_losses')
simulate_losses <- function(parameters, polExp) {}
# return dataframe of simulation losses

#Q: Store simulation results in excel or pass directly into loss_analysis?
#Q: Is number of simulation runs a parameter?