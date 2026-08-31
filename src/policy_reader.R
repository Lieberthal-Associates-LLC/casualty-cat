import(modules)
import(utils)
import(R.oo)
# Read in inputs


read_policy_data <- function(filepath = "sample_data_gen/sample_policy_data_short.csv") {
  data = tryCatch(read.csv(filepath), error = function(e) throw("Could not open CSV policy data file at ", filepath))
  rownames(data) = data$Policy.ID
  return(data)
}
# returns policy dataframe
# Every policy in the file is evaluated. The model applies an insured's ground-up
# loss to all of that insured's policies regardless of Line of Business, so
# selecting a subset of lines is a property of the input file, not of the reader.

export("input_policy_data")
input_policy_data <- function() {
  filepath = readline("Filepath of policy data (leave blank for sample_data_gen/sample_policy_data_short.csv): ")
  if(nchar(filepath) == 0) {
    return(read_policy_data())
  }
  else {
    return(read_policy_data(filepath))
  }
}




read_exposure_matrix <- function(filepath = "sample_data_gen/sample_exposure_matrix_short.csv") {
  matrix = tryCatch(read.csv(filepath, check.names = FALSE), error = function(e) throw("Could not open CSV exposure matrix file at ", filepath))
  rownames(matrix) = paste("Company", matrix$`Insured ID`)
  cat("Company exposures to activities:\n")
  print(matrix)
  cat("\n\n------------------------------------------------------------------------\n\n")
  return(matrix)
}

export("input_exposure_matrix")
input_exposure_matrix <- function() {
  filepath = readline("Filepath of exposure matrix (leave blank for sample_data_gen/sample_exposure_matrix_short.csv): ")
  if(nchar(filepath) == 0) {
    return(read_exposure_matrix())
  }
  else {
    return(read_exposure_matrix(filepath))
  }
}



