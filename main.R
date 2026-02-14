if(!require(modules)) install.packages("modules")
if(!require(files)) install.packages("files")
if(!require(EnvStats)) install.packages("EnvStats")
if(!require(R.oo)) install.packages("R.oo")
if(!require(jsonlite)) install.packages("jsonlite")
if(!require(fs)) install.packages("openxlsx2")
if(!require(openxlsx2)) install.packages("openxlsx2")


NUM_SIMULATION_RUNS = 5

policyReader = modules::use("src/policy_reader.R")
simulator = modules::use("src/loss_simulator.R")
evaluator = modules::use("src/policy_evaluator.R")
analyzer = modules::use("src/payout_analyzer.R")
parameterReader = modules::use("src/parameters.R")
exporter = modules::use("src/export_simulation.R")
analytics = modules::use("src/export_analytics.R")


compExposures = policyReader$read_exposure_matrix()
policies = policyReader$input_policy_data()
parameters = parameterReader$get_parameters()

events = list()
losses = list()
payouts = list()

if(NUM_SIMULATION_RUNS > 0) {
  for(runNumber in 1:NUM_SIMULATION_RUNS) {
    simResult = simulator$simulate_year(compExposures, parameters)
    payout = evaluator$find_payout(policies, simResult$losses)
    payouts[[runNumber]] = payout
    losses[[runNumber]] = simResult$losses
    events[[runNumber]] = simResult$events
  }
  analyzer$analyze(payouts, events, losses)
}

exporter$export_outputs(parameters, policies, compExposures, events, 
                        losses, payouts, "output/results.xlsx")
analytics$add_severity_pivot("output/results.xlsx", "events", "Severity",
                   row_field = "Run", col_field = "Event")