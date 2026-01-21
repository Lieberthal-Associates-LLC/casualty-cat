if(!require(modules)) install.packages("modules")
library(modules)

NUM_SIMULATION_RUNS = 5

reader = modules::use("src/policy_reader.R")
simulator = modules::use("src/loss_simulator.R")
evaluator = modules::use("src/policy_evaluator.R")
analyzer = modules::use("src/payout_analyzer.R")

compExposures = reader$read_exposure_matrix()
policies = reader$read_policy_data()

events = list()
losses = list()
payouts = list()

for(runNumber in 1:NUM_SIMULATION_RUNS) {
  simResult = simulator$simulate_year(compExposures)
  payout = evaluator$find_payout(policies, simResult$loss)
  payouts[[runNumber]] = payout
  losses[[runNumber]] = simResult$loss
  events[[runNumber]] = simResult$events
}
analyzer$calculate_loss_intervals(payouts)