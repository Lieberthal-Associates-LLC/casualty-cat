import(modules)
import(utils)
# Read in inputs


export("read_policy_data")
read_policy_data <- function(filepath = "sample_data_gen/sample_policy_data_short.csv") {
  data = read.csv(filepath)
  return(data)
}
# returns policy dataframe


export("read_exposure_matrix")
read_exposure_matrix <- function(filepath = "sample_data_gen/sample_exposure_matrix_short.csv") {
  matrix = read.csv(filepath)
  return(matrix)
}

read_policy_data()
#expMat = read_exposure_matrix()
#expMat["X54"]
