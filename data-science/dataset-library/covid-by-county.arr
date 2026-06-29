use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")


# Load your spreadsheet and define your table
covid-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/12RKQIJEKl6768IjgccSokrg1sWXOEAHDoP71x4c1294/")

covid-table = load-table:
  id,               # ID (unique for each row)
  county,           # County name
  state,            # State
  pop,              # total Population
  total-cases,      # Total positive Cases
  deaths,           # Total Deaths
  cases-per-100k,   # Cases per 100k
  deaths-per-100k,  # Deaths per 100k
  poverty,          # Est number of citizens in poverty
  median-income,    # Median Income
  vaxed,            # Number of citizens recieving the vaccine
  pct-vaxed,        # Percentage of citizens recieving the vaccine
  boosted,          # Number of citizens recieving the booster
  pct-boosted,      # Percentage of citizens recieving the booster
  svi,              # Social Vulnerability Index (tinyurl.com/SocialVulnIndex)
  metro             # is the county a "Metropolitan" county? (see metroextension.wsu.edu/defining-metropolitan/)
  source: covid-sheet.sheet-by-name("County Data", true)
end

#########################################################
# Define some rows
providence = row-n(covid-table, 2299)


#########################################################
# Define some helper functions
fun TX(r): r["state"] == "Texas" end
fun ND(r): r["state"] == "North Dakota" end


#########################################################
# Define random and logical subsets

Texas = filter(covid-table, TX)
# Texas has 254 counties!

N-Dakota = filter(covid-table, ND)
# North Dakota has 53 counties (a much more manageable number for pyret)

