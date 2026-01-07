if(!require(modules)) install.packages("modules")
library(modules)

NUM_SIMULATION_RUNS = 1000

reader = modules::use("src/policy_reader.R")
simulator = modules::use("src/loss_simulator.R")

compExposures = reader$read_exposure_matrix()
pLosses
for(runNumber in 1:NUM_SIMULATION_RUNS)
loss = simulator$simulate_loss(compExposures)

