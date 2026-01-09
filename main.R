if(!require(modules)) install.packages("modules")
library(modules)

NUM_SIMULATION_RUNS = 5

reader = modules::use("src/policy_reader.R")
simulator = modules::use("src/loss_simulator.R")
evaluator = modules::use("src/policy_evaluator.R")
analyzer = modules::use("src/payout_analyzer.R")

compExposures = reader$read_exposure_matrix()
policies = reader$read_policy_data()

payouts = list()
for(runNumber in 1:NUM_SIMULATION_RUNS) {
  loss = simulator$simulate_year(compExposures)
  payout = evaluator$find_payout(policies, loss)
  payouts[[runNumber]] = payout
}
analyzer$calculate_loss_intervals(payouts)