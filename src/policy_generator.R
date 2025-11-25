library(modules)
# Synthesize policy data for testing purposes

export('generate_policy_names')
generate_policy_names <- function(numPols) {
  if(numPols <=0) {return(c())}
  policyNames = paste("Policy ", 1:numPols, sep="")
  return(policyNames)
}
# return vector of policy names

export('generate_activity_names')
generate_activity_names <- function(numActs) {
  if(numActs <= 0) {return(c())}
  activityNames = paste("Activity ", 1:numActs, sep="")
  return(activityNames)
}
# return vector of activity names

sample_exposures <- function(length, probZero = 0.6, maxExposure = 1) {
  # returns a vector of measurements that are 0 with probability probZero, uniform random in [0,1] otherwise
  exposureUniforms = runif(length, max = maxExposure)
  testUniforms = runif(length)
  exposures = ifelse(testUniforms < probZero, 0, exposureUniforms)
  return(exposures)
}

export('generate_exposure_matrix')
generate_exposure_matrix <- function(pols, acts) {
  numPols = length(pols)
  numActs = length(acts)
  if(numPols == 0 || numActs == 0) {stop("Cannot generate empty exposure matrix")}
  exposuresVec = sample_exposures(numPols * numActs)
  exposuresArr = array(data = exposuresVec, dim = c(numPols, numActs), dimnames = list(pols, acts))
  return(exposuresArr)
}
# return array of exposures

#Q: Store policy matrix only in memory or allow file IO?