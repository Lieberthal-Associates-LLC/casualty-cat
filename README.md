# Catastrophe Risk Model

## Requirements
To run this program, you need:
- R
- An internet connection (to automatically install packages the first time you run the program)

## Usage
1. Run `Rscript main.R` or otherwise source main.R (e.g. Ctrl+Shift+S in RStudio).
2. When prompted, input the path to your input data files (or leave blank for default).

## Inputs
Two data file inputs are needed for the program: the company-industry exposure matrix and policy table.

These CSV files can be generated from templates in the `data_templates` directory, and samples are provided.

To create your own data file:
1. Replace the values in the corresponding Excel template in `data_templates`.
2. Export as CSV

Then each time you run the program, you can input the path to the generated CSV to run the program on the inputs you put into Excel.

## Outputs
The Excel file containing simulation results is outputted in the `outputs` directory.

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
| sevParetoShape | the Pareto shape parameter of the event severity distribution | 2 |
| alaeBeforePolicyTerms | If TRUE, the banded ALAE fraction grosses up the ground-up loss before policy terms (attachment, per-occurrence limit, remaining aggregate) are applied; if FALSE, it loads the post-policy-terms payout. The band lookup itself always uses the pre-ALAE post-policy-terms payout. | FALSE |
| alaeBandMinima | Lower bounds of the per-(policy, event) payout bands used to look up the ALAE fraction. Must be strictly increasing and start at 0. Same length as `alaeBandFractions`. | [0, 1000000, 10000000] |
| alaeBandFractions | ALAE fraction for each band: for a payout `p`, the fraction is `alaeBandFractions[i]` where `i` is the largest index with `alaeBandMinima[i] <= p` (step lookup, applied to the entire payout — not marginal). Same length as `alaeBandMinima`. | [0.125, 0.175, 0.225] |