use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

# Load your spreadsheet and define your table
snack-sheet = load-spreadsheet("PASTE THE URL FOR THE GOOGLESHEETS VERSION OF YOUR CLASS SURVEY RESULT HERE")

# load the 'animals' sheet as a table
snack-table =
  load-table: id, day, time, date, is-school-day, name, salty-sweet, servings, cal, fat, sodium, sugar, cost, ingredients, why, health-level
    source: snack-sheet.sheet-by-name("cleaned", true)
end

########################################################
# Define some rows




########################################################
# Define some helper functions


########################################################
# Define random and logical subsets

