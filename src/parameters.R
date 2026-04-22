# Handle simulation parameter values, including expert input (overrides)
import(jsonlite)
import(fs)
import(R.oo)

DEFAULT_PARAMETERS = list(
  activityNames = c(11, 21, 22, 23, 31, 42, 44, 48, 51, 52, 53, 54, 55, 56, 61, 62, 71, 72, 81, 92),
  activityProbs = rep(1/5, 20),
  zeroEventProb = 0.7,
  meanEventPoisson = 2.0,
  logShockSd = 0.05,
  sevLNormLoc = 15,
  sevLNormSd = 2,
  sevLNormProb = 0.7,
  sevParetoLoc = 1e5,
  sevParetoShape = 2,
  alaeBeforePolicyTerms = FALSE
)
SINGLE_VALUE_PARAMETERS = c("zeroEventProb", "meanEventPoisson",
                            "logShockSd", "sevLNormLoc",
                            "sevLNormSd", "sevLNormProb",
                            "sevParetoLoc", "sevParetoShape",
                            "alaeBeforePolicyTerms")

save_params <- function(parameters, saveDir, saveFile) {
  paramsJson = toJSON(parameters, pretty = TRUE, auto_unbox = FALSE)
  dir_create(saveDir)
  savePath = file.path(saveDir, saveFile)
  file.create(savePath)
  write(paramsJson, file = savePath)
} 

load_params <- function(loadDir, loadFile) {
  params = tryCatch(read_json(file.path(loadDir, loadFile), simplifyVector = TRUE), error = function(e)
    throw("Parameter file is not valid JSON"))
  print("Loaded params:")
  print(params)
  cat("\n\n------------------------------------------------------------------------\n\n")
  return(params)
}

assert <- function(condition, ...) {
  if(!condition) {
    throw(...)
  }
}

validate_parameters <- function(params) {
  for(fieldName in names(DEFAULT_PARAMETERS)) {
    assert(fieldName %in% names(params), "Required parameter ", fieldName, " is missing from parameter file")
  }
  assert(length(params$activityNames) == length(params$activityProbs), 
         "Lengths of activityNames (", length(params$activityNames), ") and activityProbs (",
         length(params$activityProbs), ") are not equal.")
  for(fieldName in SINGLE_VALUE_PARAMETERS) {
    assert(length(params[fieldName]) == 1, "Violated rule: ", fieldName, " must be a single value")
  }
  assert(params$zeroEventProb >= 0 && params$zeroEventProb <= 1, "Violated rule: 0 <= zeroEventProb <= 1")
  assert(max(params$activityProbs) <= 1, "Violated rule: activityProbs must be at most 1")
  assert(min(params$activityProbs) >= 0, "Violated rule: activityProbs must be at least 0")
  assert(params$meanEventPoisson >= 0, "Violated rule: meanEventPoisson >= 0")
  assert(params$logShockSd >= 0, "Violated rule: logShockSd >= 0")
  assert(params$sevLNormSd >= 0, "Violated rule: sevLNormSd >= 0")
  assert(params$sevLNormProb >= 0 && params$sevLNormProb <= 1, "Violated rule: 0 <= sevLNormProb <= 1")
  assert(is.logical(params$alaeBeforePolicyTerms), "Violated rule: alaeBeforePolicyTerms must be TRUE or FALSE")


}

export('get_parameters')
get_parameters <- function(overrideDir = "input", overrideFile = "parameters.json") {
  # compute parameters or import from override file path, return list of parameters
  parameters = DEFAULT_PARAMETERS
  overridePath = file.path(overrideDir, overrideFile)
  if(file.exists(overridePath)) {
    # if override is requested
    parameters = load_params(overrideDir, overrideFile)
  }  
  else {
    # regenerate default params file
    save_params(parameters, overrideDir, overrideFile)
  }
  validate_parameters(parameters)
  return(parameters)
}

