# Given simulation parameters and policy matrix, run simulation
if(!require("EnvStats")) install.packages("EnvStats")
library(EnvStats)


sampleSeverity <- function(numSamples = 1, mu = 1, sigma = 0.5, aPar = 2, lambdaPar = 5, p = 0.3) {
  # with probability p, samples X ~ LogNormal(mu, sigma)
  # with probability 1-p, samples Y ~ Pareto(aPar, lambdaPar)
  X = rlnorm(numSamples, meanlog=mu, sdlog=sigma)
  Y = rpareto(numSamples, location = lambdaPar, shape = aPar)
  U = runif(numSamples)
  severity = ifelse(U < p, yes = X, no = Y)
  return(severity)
}




export('simulate_losses')
simulate_losses <- function(parameters, polExp) {}
# return dataframe of simulation losses

#Q: Store simulation results in excel or pass directly into loss_analysis?
#Q: Is number of simulation runs a parameter?