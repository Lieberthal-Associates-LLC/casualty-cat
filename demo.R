if(!require("EnvStats")) install.packages("EnvStats")
library(EnvStats)

activities = c("P1", "P2", "P3")
coveredBusinessActivities = list(P1 = c("a", "b", "c"), P2 = c("c", "d"), P3 = c("a", "d"))

sampleSeverity <- function(numSamples, mu, sigma, aPar, lambdaPar, p) {
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
