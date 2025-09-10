if(!require("EnvStats")) install.packages("EnvStats")
library(EnvStats)

allPolicies = c("P1", "P2", "P3")
allActivities = c("a", "b", "c", "d")
activityProbability = list(a = 0.6, b = 0.3, c = 0.1, d = 0.25)
coveredBusinessActivities = list(P1 = c("a", "b", "c"), P2 = c("c", "d"), P3 = c("a", "d"))

sampleSeverity <- function(numSamples = 1, mu = 1, sigma = 0.5, aPar = 2, lambdaPar = 5, p = 0.3) {
  # with probability p, samples X ~ LogNormal(mu, sigma)
  # with probability 1-p, samples Y ~ Pareto(aPar, lambdaPar)
  X = rlnorm(numSamples, meanlog=mu, sdlog=sigma)
  Y = rpareto(numSamples, location = lambdaPar, shape = aPar)
  U = runif(numSamples)
  severity = ifelse(U < p, yes = X, no = Y)
  return(severity)
}
#sampleSeverity(10, mu = 1, sigma = 0.1, aPar = 1.5, lambdaPar = 20, p = 0.5) # test

getAffectedPolicies <- function(affectedActivities) {
  globalVariables(coveredBusinessActivities)
  affectedPolicies = c()
  for(policy in names(coveredBusinessActivities)) {
    if(length(intersect(coveredBusinessActivities[[policy]], affectedActivities)) > 0) {
      affectedPolicies = c(affectedPolicies, policy)
    }
  }
  return(affectedPolicies)
}
#getAffectedPolicies(c("b", "c")) # test

sampleEvents <- function(eventRate = 0.6) {
  # return a vector of events with fields:
  #   severity (number)
  #   activities (list of affected activities)
  globalVariables(c("allActivities", "sampleSeverity", "activityProbability"))
  numEvents <- rpois(1, eventRate)
  events = c()
  if(numEvents == 0) {return(events)}
  
  for (eventNum in 1:numEvents) {
    event <- list()
    event$severity = sampleSeverity()
    event$activities = list()
    for(activity in allActivities) {
      if(runif(1) < activityProbability[[activity]]) {
        event$activities = append(event$activities, activity)
        }
    }
    events = c(events, event)
  }
  return(events)
}
#sampleEvents()# test
