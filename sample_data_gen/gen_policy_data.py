import random; random.seed(42)
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
POLICY_OUTPUT_FILE = "sample_policy_data_short.csv"
EXPOSURE_OUTPUT_FILE = "sample_exposure_matrix_short.csv"
NUM_COMPANIES = 10
MIN_LAT, MAX_LAT = 33., 42.
MIN_LONG, MAX_LONG = -119., -80.
MIN_LOG10_EXPOSURE_AMT, MAX_LOG10_EXPOSURE_AMT = 7, 9
MIN_EXPOSURE = 0.
MAX_EXPOSURE = 0.5 / NUM_COMPANIES
SAME_INDUSTRY_EXPOSURE_ADJUSTMENT = 2.0
EXPECTED_POLICY_MULTIPLIER = 1.05
RISK_SLICE_GRANULARITY = -6
PARTITION_GRANULARITY = 1 # tenths
RISK_ID_INCREMENT_PROBABILITY = 0.9
MIN_RISK_SLICE = 0.051
MAX_RISK_SLICE = 0.2
MAX_NUM_RISK_SLICES = 5
NUMERICAL_SCALE = 1000
MIN_RISK_PER_EVENT_LIMIT = 0.1 # minimum risk per occurrence layer limit as a fraction of aggregate layer limit
MAX_POLICY_MULTIPLIER = 6
POLICIES_PER_SLICE_DISTR = {
                1: 0.8, 2: 0.1, 3: 0.05, 4: 0.05
            }
EVENT_LIMIT_FRAC_DISTR = {0.5 : 0.5, 1 : 0.25, 1/3 : 0.15, 1/4 : 0.1}
# print(MIN_RISK_PER_EVENT_LIMIT * 10** MIN_LOG10_EXPOSURE_AMT * MIN_RISK_SLICE
#              / MAX_POLICIES_PER_SLICE / MAX_POLICY_MULTIPLIER)
# assert round(MIN_RISK_PER_EVENT_LIMIT * 10** MIN_LOG10_EXPOSURE_AMT * MIN_RISK_SLICE
#              / MAX_POLICIES_PER_SLICE / MAX_POLICY_MULTIPLIER, RISK_SLICE_GRANULARITY) > 0
assert MAX_RISK_SLICE * MAX_NUM_RISK_SLICES <= 1. # no chance of overflowing risk tower
assert MIN_RISK_SLICE * 10 ** MIN_LOG10_EXPOSURE_AMT >= 0.5 * 10**RISK_SLICE_GRANULARITY # no chance of empty slices

POLICIES_PER_SLICE_SUPPORT = np.array(list(POLICIES_PER_SLICE_DISTR.keys()))
POLICIES_PER_SLICE_PROB = np.array([POLICIES_PER_SLICE_DISTR[x] for x in POLICIES_PER_SLICE_SUPPORT])

EVENT_LIMIT_FRAC_SUPPORT = np.array(list(EVENT_LIMIT_FRAC_DISTR.keys()))
EVENT_LIMIT_FRAC_PROB = np.array([EVENT_LIMIT_FRAC_DISTR[x] for x in EVENT_LIMIT_FRAC_SUPPORT])


STATE_NAMES = [
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
]
LINES_OF_BUSINESS = [
    "General Liability",
    "Auto Liability",
    "Product Liability",
    "Professional Liability",
    "Medical Malpractice",
    "Workers Compensation",
    "Employment Practices (EPLI)",
    "Umbrella",
    "Directors & Officers",
    "Property, Inland Marine"
]
ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
ACT_NAMES = [11, 21, 22, 23, 31, 42, 44, 48, 51, 52, 53, 54, 55, 56, 61, 62, 71, 72, 81, 92]
PERILS = [
    "Cyber/AI",
    "Environmental",
    "Errors/Omissions",
    "Infrastructure/Operations",
    "Legal/Regulatory",
    "Mass Tort",
    "Product",
    "Supply Chain",
    "Systematic",
    "Workplace Incident"
]

EXPOSURE_BASES = ["Payroll", "Revenue", "Sales", "Number of Employees"]

def gen_random_dates(startDateStr, endDateStr, yearsSupport : list[int], yearsFreqs : list[float]):
    startDate = pd.to_datetime(startDateStr)
    endDate = pd.to_datetime(endDateStr)
    delta = endDate - startDate
    randomNumDays = random.randrange(delta.days)
    randomDelta = timedelta(days = randomNumDays)
    firstDate = startDate + randomDelta
    secondDate = firstDate + timedelta(days = 365 * int(np.random.choice(yearsSupport, p = yearsFreqs)))
    return str(firstDate), str(secondDate) 

def sample_discrete(support, probs):
    return np.random.choice(support, p = probs)

def gen_partition(numParts):
    parts = []
    amountLeft = 1.
    for i in range(numParts - 1):
        part = random.uniform(0, amountLeft)
        part = round(part, PARTITION_GRANULARITY)
        amountLeft -= part
        parts.append(part)
    parts.append(amountLeft)
    return parts    

def trim_float(x):
    if x == 0.:
        return "0"
    highestDigit = int(np.log10(abs(x)))-1 # -1 for (.1, 1]
    precision = max(0, -highestDigit+2)
    return f"{x:.{precision}f}"

def numToLetters(i : int):
    left, right = divmod(i, 26)
    if left == 0:
        return ALPHABET[right]
    return f"{left}{ALPHABET[right]}"

class Company:
    def __init__(self, compId, compName, coords, state,
                  industry, actExposures, expAmount):
        if actExposures.keys() != set(ACT_NAMES):
            raise Exception("Company missing keys in exposures")
        self.id = compId
        self.name = compName
        self.actExposures = actExposures
        self.latitude = coords[0]
        self.longitude = coords[1]
        self.state = state
        self.industry = industry
        self.exposedAmount = expAmount
        self.risk_slices = self.gen_risk_slices()
    def get_id(self):
        return self.id
    def to_dict(self):
        return {
            "Exposed Amount": self.exposedAmount,
            **{name : self.actExposures[name] for name in self.actExposures}
        }
    
    def gen_risk_slices(self, maxNumSlices = MAX_NUM_RISK_SLICES, minSlice = MIN_RISK_SLICE, maxSlice = MAX_RISK_SLICE):
        numSlices = random.randrange(1, maxNumSlices+1)
        topThresh = 1. * self.exposedAmount
        bottomThresh = 1. * self.exposedAmount
        
        slices = []
        for sliceInd in range(numSlices):
            sliceWidth = self.exposedAmount * random.uniform(minSlice, maxSlice)
            sliceWidth = round(sliceWidth, RISK_SLICE_GRANULARITY)
            if sliceWidth == 0:
                print(f"size 0 slice")
                continue
            bottomThresh = topThresh - sliceWidth
            slices.append((bottomThresh, topThresh))
            topThresh = bottomThresh
        return slices

    def __str__(self):
        return (
f"""{self.name} (id {self.id}): 
    Industry: {self.industry}
    Exposed amount: {self.exposedAmount}
    Location: ({self.latitude}, {self.longitude:.4f}), {self.state}
    Exposures: {[f'{self.actExposures[act]:.6f}' for act in ACT_NAMES]}
""")
    def __repr__(self):
        return str(self)
class Policy:
    nextPolId = 0
    def __init__(self, comp: Company, polCount, riskId, startDate, endDate,
                 renewalInd, alaeIncluded, lineOfBusiness, perils,
                 expBase, riskFloor, riskCeil, participation,
                 expGrossLossRatio, riskPerEventLimit, riskAggLayerLimit
                 ):
        self.id = Policy.nextPolId
        Policy.nextPolId += 1
        self.comp = comp
        self.polCount = polCount
        self.riskId = numToLetters(riskId)
        self.startDate = startDate
        self.endDate = endDate
        self.renewalInd = renewalInd
        self.alaeIncluded = "Yes" if alaeIncluded else "No"
        self.lineOfBusiness = lineOfBusiness
        self.perils = perils
        self.expBase = expBase
        self.riskFloor = riskFloor
        self.riskCeil = riskCeil
        self.participation = participation
        self.expGrossLossRatio = expGrossLossRatio
        self.riskPerEventLimit = riskPerEventLimit
        self.perilDict = {f"Covers {peril}" : ("Yes" if peril in self.perils else "No") for peril in PERILS}
        self.rectWidth = self.riskCeil - self.riskFloor
        self.riskAggLayerLimit = riskAggLayerLimit
    def get_id(self):
        return self.id
    def to_dict(self):
        return {
                "Insured ID": self.comp.id,
                "Policy Count": self.polCount,
                "Risk ID" : self.riskId,
                "Insured Name": self.comp.name,
                "Insured Address": self.comp.state,
                "Insured Latitude": self.comp.latitude,
                "Insured Longitude": self.comp.longitude,
                "Policy Inception Date": self.startDate,
                "Policy Expiration Date": self.endDate,
                "Renewal Indicator": "Yes" if self.renewalInd else "No",
                "ALAE Included" : self.alaeIncluded,
                "Line of Business": self.lineOfBusiness,
                "Insured Industry": self.comp.industry,
                **(self.perilDict),
                "Exposure Base": self.expBase,
                "Exposure Amount" : self.comp.exposedAmount / NUMERICAL_SCALE,
                "Deductible / Self-Insured Retention": min(slice[0] for slice in self.comp.risk_slices) / NUMERICAL_SCALE,
                "Attachment Point for Excess Treaties": self.riskFloor / NUMERICAL_SCALE,
                "Participation": self.participation,
                "Expected Gross Loss Ratio": self.expGrossLossRatio,
                "Risk per Occurrence Layer Limit": self.riskPerEventLimit / NUMERICAL_SCALE,
                "Risk Annual Aggregate Layer Limit": self.riskAggLayerLimit / NUMERICAL_SCALE
                }
def gen_comp_name(nameLength = 3):
    return "".join(random.choices(ALPHABET, k = nameLength))
        
def gen_comps(numComps = NUM_COMPANIES):
    companies = []# id : Company
    for compId in range(numComps):
        compName = gen_comp_name()
        coords = (random.uniform(MIN_LAT, MAX_LAT),
                  random.uniform(MIN_LONG, MAX_LONG))
        state = random.choice(STATE_NAMES)
        industry = random.choice(ACT_NAMES)
        exposedAmt = 10 ** random.uniform(MIN_LOG10_EXPOSURE_AMT, MAX_LOG10_EXPOSURE_AMT)
        exposedAmt = round(exposedAmt, RISK_SLICE_GRANULARITY)
        actExposures = {act : random.uniform(MIN_EXPOSURE, MAX_EXPOSURE) for act in ACT_NAMES}
        actExposures[industry] *= SAME_INDUSTRY_EXPOSURE_ADJUSTMENT
        actExposures[industry] = min(1, actExposures[industry])
        company = Company(
            compId, compName, coords, state,
            industry, actExposures, exposedAmt
        )
        companies.append(company)
    return companies

def gen_comp_policies(comp : Company, policyList : list[Policy], policyDensity = 0.8):
    riskId = 0
    for [riskFloor, riskCeil] in comp.risk_slices:
        # if riskFloor == riskCeil:
        #     print(f"Size 0 chunk")
        #     continue
        for lineOfBusiness in LINES_OF_BUSINESS:
            if random.random() > policyDensity:
                continue
            numPolicies = sample_discrete(POLICIES_PER_SLICE_SUPPORT, POLICIES_PER_SLICE_PROB)
            # participations = gen_partition(numPolicies)
            for policyIdx in range(numPolicies):
                participation = 1 / numPolicies
                startDate, expDate = gen_random_dates(startDateStr = "Jan 1, 2020", endDateStr = "Jan 1, 2024", yearsSupport = [1, 2, 3, 4, 5], yearsFreqs = [.8, .1, .05, .025, .025])
                renewalInd = random.choice([True, False])
                alaeIncluded = random.choice([True, False])
                # renewalInd = "Yes"
                numPerils = random.randrange(1, len(PERILS))
                perils = random.sample(PERILS, numPerils)
                expBase = random.choice(EXPOSURE_BASES)
                expGrossLossRatio = random.uniform(0.5, 0.9)
                policyMultiplier = 1 + np.random.poisson(EXPECTED_POLICY_MULTIPLIER - 1)
                policyMultiplier = min(policyMultiplier, MAX_POLICY_MULTIPLIER)
                participation /= policyMultiplier
                riskAggLayerLimit = (riskCeil - riskFloor)
                riskAggLayerLimit = round(riskAggLayerLimit, RISK_SLICE_GRANULARITY)
                perEventFrac = sample_discrete(EVENT_LIMIT_FRAC_SUPPORT, EVENT_LIMIT_FRAC_PROB)
                riskPerEventLimit = riskAggLayerLimit * perEventFrac
                policy = Policy(comp, policyMultiplier, riskId, startDate, expDate, renewalInd, alaeIncluded, lineOfBusiness, perils,
                                expBase, riskFloor, riskCeil, participation, expGrossLossRatio, riskPerEventLimit, riskAggLayerLimit)
                policyList.append(policy)
                if random.random() < RISK_ID_INCREMENT_PROBABILITY:
                    riskId += 1
"""def __init__(self, polId, comp: Company, polCount, startDate, endDate,
                 renewalInd, lineOfBusiness, perils,
                 expBase, riskFloor, riskCeil, participation,
                 expGrossLossRatio, riskPerEventLimit
                 ):"""

companies = gen_comps()
policies = []
for comp in companies:
    gen_comp_policies(comp, policies)

policyFrame = pd.DataFrame(columns = policies[0].to_dict().keys())
for policy in policies:
    policyId = policy.get_id()
    policyFrame.loc[policyId] = policy.to_dict()
policyFrame.rename_axis(index = "Policy ID", inplace = True)
print(policyFrame)
policyFrame.to_csv(POLICY_OUTPUT_FILE, float_format=trim_float)

exposureFrame = pd.DataFrame(columns = companies[0].to_dict().keys())
for comp in companies:
    compId = comp.get_id()
    exposureFrame.loc[compId] = comp.to_dict()
exposureFrame.rename_axis(index = "Insured ID", inplace = True)
print(exposureFrame)
exposureFrame.to_csv(EXPOSURE_OUTPUT_FILE, float_format=trim_float)
# naics = {11: "Agriculture, Forestry, Fishing, and Hunting",
#          21: "Mining",
#          22: "Utilities",
#          23: "Construction",
#          31: "Manufacturing",
#          42: "Wholesale Trade",
#          44: "Retail Trade",
#          48: "Transportation and Warehousing",
#          51: "Information",
#          52: "Finance and Insurance",
#          53: "Real Estate Rental and Leasing",
#          54: "Professional, Scientific, and Technical Services",
#          55: "Management of Companies and Enterprises",
#          56: "Administrative and Support and Waste Management and Remediation Services",
#          61: "Educational Services",
#          62: "Health Care and Social Assistance",
#          71: "Arts, Entertainment, and Recreation",
#          72: "Accommodation and Food Services",
#          81: "Other Services (except Public Administration)",
#          92: "Public Administration",
#          }
