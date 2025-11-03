# Synthesize policy data for testing purposes

export('generate_policy_names')
generate_policy_names <- function(numPols) {}
# return vector of policy names

export('generate_activity_names')
generate_activity_names <- function(numActs) {}
# return vector of line names

export('generate_exposures')
generate_exposures <- function(pols, acts) {}
# return data frame of exposures

#Q: Store policy matrix only in memory or allow file IO?