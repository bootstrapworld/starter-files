use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
voter-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1uhnZVz9OFsnI8rNpdIiw5ZcxnstaKMAE8BQ285KZxfQ")

voter-table = load-table:
  state,            # name of State
  total-pop,        # Total Population
  total-citizens,   # Total number of Citizens
  female,           # total number of Females
  male,             # total number of Males
  white,            # total number of white people
  total-r,          # Total number of registered voters
  pct-r,            # Percentage of citizens registered to vote
  pct-r-above-avg,  # was the Percentage registered voters above natl average?
  pct-fem-r,        # Percentage of Registered Female voters
  pct-male-r,       # Percentage of Registered Male voters
  pct-white-r,      # Percentage of Registered White voters
  more-female-r,    # are more Females Registered to vote than males?
  more-white-r,     # are more White voters Registered to vote than non-whites?
  total-voted,      # Total number of citizens who Voted
  pct-v,            # Percentage of citizens who Voted
  pct-v-above-avg,  # was the Percentage of citizens who Voted above the natl average?
  pct-fem-v,        # Percentage of Females who Voted
  pct-male-v,       # Percentage of Males who Voted
  pct-white-v,      # Percentage of White people who Voted
  more-female-v,    # did More Females vote than males?
  more-white-v,     # did More White people vote than non-whites?
  difference-r-v    # Difference between number of people registered and those who voted
  source: voter-sheet.sheet-by-name("turnout2016", true)
end

#reg = registered to vote
#pct = percent
#v = voted
# other than the column for total population, all columns are based on the sector of the population with citizenship status

#########################################################
# Define some rows
voter-sample-row = row-n(voter-table, 0)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


