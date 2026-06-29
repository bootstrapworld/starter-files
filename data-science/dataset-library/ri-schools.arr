use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet
ri-schools-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1XeeyAuF_mtpeCw2HVCKjvwW1rreNvztoQ3WeBlEaDl0/")

#Load the "2018" Sheet as a table. Comments explain column content.
schools-table = load-table:
  district,          # School District
  school,            # School Name
  ela-passing,       # % passed English Language Arts in 2018
  math-passing,      # % passed Math in 2018
  is-charter,        # returns True if it's a charter school
  free-lunch,        # students eligible for free lunch
  reduced-lunch,     # students eligible for reduced lunch
  native,            # students who identify as American Indian / Alaska Native
  pacific-islander,  # students who identify as Native Hawaiian / other Pacific Islander
  hispanic,          # students who identify as Hispanic
  black,             # students who identify as Black or African American
  white,             # students who identify as White
  multi-racial,      # students who identify as two or more races
  male,              # students who identify as male
  female,            # students who identify as female
  total-pop          # total population
  source: ri-schools-sheet.sheet-by-name("2018", true)
end

#########################################################
# Define some rows
barringtonHS = row-n(schools-table, 0)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


