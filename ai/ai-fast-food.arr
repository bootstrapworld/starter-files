use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")
fast-food-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1INp_O7oOwY68694lScyEUNbbHTpOCQA0RPQQXQR9URo/")

fast-food = load-table: 
  id, 
  restaurant,  
  price, 
  fries, 
  burgers
  source: fast-food-sheet.sheet-by-name("data", true) 
end


##################################
# Define some rows
mc-donalds = row-n(fast-food, 0)
in-n-out   = row-n(fast-food, 5)

##################################
# Similarity Functions
# simple-similarity   :: Table, String, List<String> -> Table
# distance-similarity :: Table, String, List<String> -> Table
# angle-similarity    :: Table, String, List<String> -> Table
# cosine-similarity   :: Table, String, List<String> -> Table