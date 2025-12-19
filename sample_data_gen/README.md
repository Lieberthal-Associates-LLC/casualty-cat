## Company Generation
| Field Name | Generation Procedure |
| ---------- | ---------------------------- |
| ID | Assigned sequentially |
| Name | Random 3-letter sequence |
| Coordinates | Randomly sampled in a rectangle |
| State | Randomly sampled (independently of coordinates) |
| Industry | Randomly sampled |
| Activity Exposures (not outputted) | Randomly sampled from $\mathrm{Unif}(0, \frac{0.5}{\text{number of companies}})$, after which the exposure corresponding to the company's own industry is doubled. |
| Exposure Amount | Randomly sampled as $10^{\mathrm{Unif}(7, 9)}$. |
| Risk Slices (Rectangles) | The number of slices is randomly sampled between 1 and 5. Heights are sampled between 5% and 20% of the exposure amount. Slices are stacked sequentially with no overlap and no gaps. All risk slice bounds are rounded to the millions after sampling. |



## Policy Generation

For each company, we iterate through its risk slices. For every pair $(\text{risk slice}, \text{line of business})$, we generate a nonzero number of policies. This number of policies for a given slice is $N \sim \mathrm{Discrete}[1 \mathrm{\ wp\ } 0.8,\ 2 \mathrm{\ wp\ } 0.1,\ 3 \mathrm{\ wp\ } 0.05,\ 4 \mathrm{\ wp\ } 0.05]$, iid. From there:

| Field Name | Generation Procedure |
| ---------- | ---------------------------- |
| Policy ID | Sequentially assigned |
| Policy Count | Sampled from $1 + \mathrm{Pois}(0.05)$ |
| Participation | Computed as $\frac{1}{N \cdot (\text{policy count})}$  |
| Policy Inception Date | Randomly sample date in the past |
| Policy Expiration Date | Sampled as $(\text{policy inception date})+ Y \text{ years}$, where $Y \sim \mathrm{Discrete}[1 \mathrm{\ wp\ } 0.8,\ 2 \mathrm{\ wp\ } 0.1,\ 3 \mathrm{\ wp\ } 0.05,\ 4 \mathrm{\ wp\ } 0.025,\ 5 \mathrm{\ wp\ } 0.025]$   |
| Renewal Indicator | Randomly selected |
| ALAE Included | Randomly selected |
| Line of Business | Randomly selected (can vary between multiple policies on the same risk rectangle) |
| Perils ("Covers X") | Randomly sample the number of covered perils between 1 and the total number of known perils. Randomly sample that number of perils from the list of known perils, without replacement. |
| Exposure Base | Randomly selected (on policy level)|
| Expected Gross Loss Ratio | Randomly sampled from $\mathrm{Unif}(0.5, 0.9)$ |
| Risk per Occurence Layer Limit | Randomly sampled from $(\text{risk slice height}) \cdot \mathrm{Discrete}[\frac12 \mathrm{\ wp\ } 0.5,\ 1 \mathrm{\ wp\ } 0.25,\ \frac13 \mathrm{\ wp\ } 0.15,\ \frac14 \mathrm{\ wp\ } 0.1]$ |
| Risk Annual Aggregate Layer Limit | Equal to $\text{risk slice height}$ |

All dollar amounts are downscaled by 1000. All numerical values are truncated to 2 significant figures after the decimal point before being outputted.

20% of policies are removed to account for not every company getting every slice / line of business insured.