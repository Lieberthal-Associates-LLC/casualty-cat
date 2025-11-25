## Company Generation
| Field Name | Generation Procedure |
| ---------- | ---------------------------- |
| ID | Assigned sequentially |
| Name | Random 3-letter sequence |
| Coordinates | Randomly sampled in a rectangle |
| State | Randomly sampled (independently of coordinates) |
| Industry | Randomly sampled |
| Activity Exposures (not outputted) | Randomly sampled from $\mathrm{Unif}(0, \frac{0.5}{\text{number of companies}})$, after which the exposure corresponding to the company's own industry is doubled. |
| Exposure Amount | Randomly sampled as $10^{\mathrm{Unif}(3, 8)}$. |
| Risk Slices (Rectangles) | The number of slices is randomly sampled between 1 and 5. Widths are sampled between 5% and 15% of the exposure amount. Slices are stacked sequentially with no overlap and no gaps. |

## Policy Generation

We generate a nonzero number of policies for each slice of each company's risk. The number of policies for a given slice is $1 + \mathrm{Pois}(0.2)$, iid. Partition the participation randomly into that many chunks, adding up to 100%. From there:

| Field Name | Generation Procedure |
| ---------- | ---------------------------- |
| Policy ID | Sequentially assigned |
| Policy Count | Sampled $1 + \mathrm{Pois}(0.05)$ |
| Policy Inception Date | Randomly sample date in the past |
| Policy Expiration Date | Randomly sample date in the future |
| Renewal Indicator | Always "Yes" |
| Line of Business | Randomly selected (can vary between multiple policies on the same risk rectangle) |
| Perils ("Covers X") | Randomly sample the number of covered perils between 1 and the total number of known perils. Randomly sample that number of perils from the list of known perils, without replacement. |
| Exposure Base | Randomly selected (on policy level)|
| Expected Gross Loss Ratio | Randomly sampled from $\mathrm{Unif}(0.1, 0.9)$ |
| Risk per Occurence Layer Limit | Randomly sampled from $\mathrm{Unif}(0.1, 1) \cdot (\text{risk rectangle width}) \cdot \frac{\text{participation}}{\text{policy count}}$ |
| Risk Annual Aggregate Layer Limit | Computed as $(\text{risk rectangle width}) \cdot \frac{\text{participation}}{\text{policy count}}$ |


