# Handle simulation parameter values, including expert input (overrides)

export('get_parameters')
get_parameters <- function(overridePath = "data/parameter_override.csv") {
  parameters = list(
    activityNames = c(11, 21, 22, 23, 31, 42, 44, 48, 51, 52, 53, 54, 55, 56, 61, 62, 71, 72, 81, 92),
    activityProbs = rep(1/5, 20),
    zeroEventProb = 0.7,
    meanEventPoisson = 2.0,
    logShockSd = 0.05)
  return(parameters)
}
# compute parameters or import from override file path, return list of parameters

