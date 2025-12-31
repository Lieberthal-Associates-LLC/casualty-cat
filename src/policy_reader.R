library(modules)
# Read in inputs

export("read_policy_data")
read_policy_data <- function(filepath = "sample_data_gen/sample_policy_data_short.csv") {
  data = read.csv(filepath)
  return(data)
}
# returns policy dataframe

read_policy_data()
