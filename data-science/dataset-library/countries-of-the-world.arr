use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
#########################################################
# Load your spreadsheet
countries-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1B6Pg-kcPoxkVD5MOGzS_ABrLS6hfLSfcHTYY0cHm2kU/")

# Define your table
countries-table = load-table: # List all of the columns in your table
  country,             # e.g. Mexico
  continent,           # e.g. North America
  has-univ-healthcare, # True if the country provides health care for its citizens
  median-lifespan,     # How long people in the country are expected to live
  gdp,                 # Gross Domestic Product - The amount of money the country makes
  population,          # Number of people living in the country
  pc-gdp               # GDP per capita (per person) in thousands of US dollars
  source: countries-sheet.sheet-by-name("2019", true)
end


#########################################################
# Define some rows
afghanistan = row-n(countries-table, 0)





#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


