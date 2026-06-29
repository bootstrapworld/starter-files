use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
fastfood-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/12yhGT-p1yMXXig27pvMEkC_E5a3tLRlXA1sXopHgwzI")

# load the 'food' sheet as a table
fastfood-table = load-table:
  name,          # name of food
  category,      # kind of food
  vendor,        # company that sells the food
  cals,          # how many calories in the item?
  fat,           # how many grams of fat in the item?
  protein,       # how many protein of fat in the item?
  carbs,         # how many grams of carbs in the item?
  chol,          # how many milligrams of cholesterol in the item?
  sat-fat,       # how many grams of saturated fat in the item?
  sodium,        # how many milligrams of sodium in the item?
  grams-serving, # how many grams in a serving?
  grams-200cal   # how many grams in a 200-calorie serving
  source: fastfood-sheet.sheet-by-name("fastfoods",
true)
end

#########################################################
# Define some rows

biscuit = row-n(fastfood-table,
0)

#########################################################
# Define some helper functions


#########################################################
# Define random and logical subsets


#########################################################
# Define charts