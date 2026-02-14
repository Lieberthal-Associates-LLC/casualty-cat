# Catastrophe Risk Model

## Requirements
To run this program, you need:
- R
- An internet connection (to automatically install packages the first time you run the program)

## Usage
1. Run `Rscript main.R` or otherwise source main.R

## Parameters
To vary model parameters, edit `input/parameters.json`, which is regenerated every time you run the program. To reset to defaults, delete `input/parameters.json`.

The parameters are:

| Parameter Name | Notes | Default |
| ---------- | ---------------------------- | ----- |
| activityNames | Names of business activities that can be affected by catastrophe events. MUST match the columns in the exposure matrix. | [11, 21, 22, 23, 31, 42, 44, 48, 51, 52, 53, 54, 55, 56, 61, 62, 71, 72, 81, 92] |
| activityProbs | Probability of an event affecting the corresponding business activity. MUST match activityNames in length. | [0.2] * 20 |
| zeroEventProb | The inflation factor of the zero-inflated Poisson random variable determining how many events occur in a simulation path. | 0.7 |
| meanEventPoisson | The Poisson mean parameter of the zero-inflated Poisson random variable determining how many events occur in a simulation path. | 2 |
| logShockSd | The log standard deviation parameter of the lognormal idiosyncratic shock that scales each (company, event, activity) combination's loss. | 0.05
| sevLNormLoc | The lognormal location parameter of the event severity distribution | 15 |
| sevLNormSd | The lognormal log standard deviation parameter of the event severity distribution | 2 |
| sevLNormProb | the lognormal probability parameter of the event severity distribution | 0.7 |
| sevParetoLoc | the Pareto location parameter of the event severity distribution | 100000 |
| sevParetoShape | the Pareto shape parameter of the event severity distribution |