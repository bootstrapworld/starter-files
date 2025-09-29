use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")


# Load your spreadsheet
food-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1DYVHT7SSjnoDp4MQ80Z1qZSqFdEIlR8Gd20eMx9f1JA")

# Define your table and add notes about the columns
# Note: per capita means per person
food-table = load-table:
  country,
  food-ind,      # produce at least as much food as import
  grain-ind,     # produce at least as much rice/wheat/corn as import
  pct-land-ag,   # % of land used for agriculture
  pop-density,   # people per sq km
  gdp-pc,        # gross domestic product per capita (a measure of the economy)
  pct-ow,        # % of adults who are obese or overweight
  co2,           # annual CO2 emissions per capita (tonnes)
  cal-pc,        # daily per capita caloric supply
  animal-p,      # protein from meat, eggs, dairy (grams per capita per day)
  plant-p,       # protein from plants (grams per capita per day)
  rel-maj,       # religious majority
  region,
  landlocked,    # not directly connected to any ocean
  pop            # population
  source: food-sheet.sheet-by-name("Sheet1", true)
end

#########################################################
# Define some rows





#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets