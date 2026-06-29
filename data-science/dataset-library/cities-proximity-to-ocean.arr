use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
data-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/166F2V0uPtAIiU4BkITu8pDmU2hnPIWJaM3yDoOHyon0")

cities-table = load-table:
  city,          # name of City
  country,       # Country
  population,    # city Population
  continent,     # Continent
  elevation,     # city Elevation
  distance-from-shore, # Distance from the nearest body of water
  gdp-per-capita # GDP per-capita
  source: data-sheet.sheet-by-name("Data", true)
end


#########################################################
# Define some rows
hanoi = row-n(cities-table, 56)
amsterdam = row-n(cities-table, 686)



#########################################################
# Define some helper functions



#########################################################
# Define random and logical subsets


