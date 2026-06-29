use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
refugees-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1mDSr7CcpSO4aL-iV2oEfYLecssvis2Je6hN3vsomYuc")

# load the 'refugees' sheet as a table
refugees-table = load-table:
  country,    # name of Country
  region,     # name of Region
  refugees,   # % of global Refugees coming from this country
  population, # total Population of this country
  sec,        # personal security index (0=least, 100=most)
  democracy,  # how democratic is the country?
  lib,        # civil liberties index (7=least, 1=most)
  dev         # human development index (0=least, 1=most)
  source: refugees-sheet.sheet-by-name("refugees", true)
end

#########################################################
# Define some rows
syria = row-n(refugees-table, 130)
canada = row-n(refugees-table, 23)



#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets

