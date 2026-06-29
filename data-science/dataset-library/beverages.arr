use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
beverages-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1QcPosMRFMrgayav6W3SfRjdtCn5oF_CSvoJPMmA2fJM/")

# load the 'beverages' sheet as a table
beverages-table = load-table:
  name,        # name of drink
  category,    # kind of drink
  sugar-free,  # is the drink sugar-free?
  calories,    # how many calories per serving?
  fat,         # how many grams of fat per serving?
  protein,     # how many grams of protein per serving?
  carbohydrate,# how many grams of carbs per serving?
  sugar,       # how many grams of sugar per serving?
  sodium,      # how many milligrams of sodium per serving?
  caffeine,    # how many milligrams of caffeine per serving?
  serving-g,   # how many grams in a serving?
  serving-oz,  # how many ounces in a serving?
  grams-200cal # how many grams in a 200-calorie serving
  source: beverages-sheet.sheet-by-name("beverages", true)
end

#########################################################
# Define some rows

black-tea = row-n(beverages-table, 7)
brewed-coffee = row-n(beverages-table, 10)

#########################################################
# Define some helper functions


#########################################################
# Define random and logical subsets


#########################################################
# Define charts