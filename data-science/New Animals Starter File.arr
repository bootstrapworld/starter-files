use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")

########################################################
# Load your spreadsheet
shelter-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1N1qzLmNQhdC3KZ8vy9dApQxk51nhz0S8f10BD0xoaBs")

# load the 'animals' sheet as a table
animals-table = load-table: name, species, sex, age, fixed, legs, pounds, weeks
  source: shelter-sheet.sheet-by-name("pets", true)
end

########################################################
# Define some rows







########################################################
# Define some helper functions







########################################################
# Define random and logical subsets