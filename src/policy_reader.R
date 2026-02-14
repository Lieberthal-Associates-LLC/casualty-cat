import(modules)
import(utils)
import(R.oo)
# Read in inputs


export("input_policy_data")
input_policy_data <- function() {
  filepath = readline("Filepath of policy data file (leave blank for sample_data_gen/sample_policy_data_short.csv): ")
  if(nchar(filepath) == 0) {
    return(read_policy_data())
  }
  else {
    return(read_policy_data(filepath))
  }
}

read_policy_data <- function(filepath = "sample_data_gen/sample_policy_data_short.csv") {
  data = tryCatch(read.csv(filepath), error = function(e) throw("Could not open CSV policy data file at ", filepath))
  rownames(data) = data$Policy.ID
  data = data[data$Line.of.Business == "General Liability",]
  return(data)
}
# returns policy dataframe


export("read_exposure_matrix")
read_exposure_matrix <- function(filepath = "sample_data_gen/sample_exposure_matrix_short.csv") {
  matrix = read.csv(filepath, check.names = FALSE)
  rownames(matrix) = paste("Company", matrix$`Insured ID`)
  cat("Company exposures to activities:\n")
  print(matrix)
  cat("\n\n------------------------------------------------------------------------\n\n")
  return(matrix)
}
