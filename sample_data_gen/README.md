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
| Risk Slices (Rectangles) | The number of slices is randomly sampled between 1 and 5. Widths are sampled between 5% and 15% of the exposure amount. Slices are stacked sequentially with no overlap and no gaps. |



## Policy Generation

For each company, we iterate through its risk slices. For every pair $(\text{risk slice}, \text{line of business})$, we generate a nonzero number of policies. This number of policies for a given slice is $N \sim 1 + \mathrm{Pois}(0.2)$, iid. From there:

| Field Name | Generation Procedure |
| ---------- | ---------------------------- |
| Policy ID | Sequentially assigned |
| Policy Count | Sampled from $1 + \mathrm{Pois}(0.05)$ |
| Participation | Computed as $\frac{1}{N \cdot (\text{policy count})}$  |
| Policy Inception Date | Randomly sample date in the past |
| Policy Expiration Date | Sampled as $(\text{policy inception date})+ Y \text{ years}$, where $P(Y=i)=[.8, .1, .05, .025, .025][i]$   |
| Renewal Indicator | Randomly selected |
| ALAE Included | Randomly selected |
| Line of Business | Randomly selected (can vary between multiple policies on the same risk rectangle) |
| Perils ("Covers X") | Randomly sample the number of covered perils between 1 and the total number of known perils. Randomly sample that number of perils from the list of known perils, without replacement. |
| Exposure Base | Randomly selected (on policy level)|
| Expected Gross Loss Ratio | Randomly sampled from $\mathrm{Unif}(0.5, 0.9)$ |
| Risk per Occurence Layer Limit | Randomly sampled from $\mathrm{round}(\mathrm{Unif}(0.1, 1) \cdot (\text{risk slice width})) \cdot (\text{participation})$ |
| Risk Annual Aggregate Layer Limit | Equal to $\text{risk slice width}$ |

All dollar values are rounded to the millions after sampling (except Risk per Occurrence Layer Limit, described above), then eventually downscaled by 1000. Risk per Occurrence Layer Limit may be rounded to 0, in which case we bump it up to $\$1M \cdot (\text{participation})$. All numerical values are truncated to 2 significant figures after the decimal point before being outputted.

20% of policies are removed to account for not every company getting every slice / line of business insured.