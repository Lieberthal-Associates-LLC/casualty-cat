# Handle simulation parameter values, including expert input (overrides)
import(jsonlite)
import(fs)

save_params <- function(parameters, saveDir, saveFile) {
  paramsJson = toJSON(parameters, pretty = TRUE, auto_unbox = FALSE)
  dir_create(saveDir)
  savePath = file.path(saveDir, saveFile)
  file.create(savePath)
  write(paramsJson, file = savePath)
} 

load_params <- function(loadDir, loadFile) {
  params = read_json(file.path(loadDir, loadFile), simplifyVector = TRUE)
  print("Loaded params:")
  print(params)
  cat("\n\n------------------------------------------------------------------------\n\n")
  return(params)
}

export('get_parameters')
get_parameters <- function(overrideDir = "input", overrideFile = "parameters.json") {
  parameters = list(
    activityNames = c(11, 21, 22, 23, 31, 42, 44, 48, 51, 52, 53, 54, 55, 56, 61, 62, 71, 72, 81, 92),
    activityProbs = rep(1/5, 20),
    zeroEventProb = 0.7,
    meanEventPoisson = 2.0,
    logShockSd = 0.05,
    sevLNormLoc = 15,
    sevLNormSd = 2,
    sevLNormProb = 0.7,
    sevParetoLoc = 1e5,
    sevParetoShape = 2
    )
  overridePath = file.path(overrideDir, overrideFile)
  if(file.exists(overridePath)) {
    # if override is requested
    parameters = load_params(overrideDir, overrideFile)
  }  
  else {
    # regenerate default params file
    save_params(parameters, overrideDir, overrideFile)
  }
  return(parameters)
}
# compute parameters or import from override file path, return list of parameters
