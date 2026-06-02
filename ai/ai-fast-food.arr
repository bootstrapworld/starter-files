use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")
fast-food-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1INp_O7oOwY68694lScyEUNbbHTpOCQA0RPQQXQR9URo/")

fast-food = load-table: 
  ID, 
  restaurant,  
  price, 
  fries, 
  burgers
  source: fast-food-sheet.sheet-by-name("data", true) 
end

##################################
# restaurant-img :: Row -> Image
# given a row from the fast-food table, produce a distinct dot

fun restaurant-img(r): 
  if      (r["restaurant"]  ==  "In-N-Out")    :  circle(6, "solid", "sea-green")  
  else if (r["restaurant"]  ==  "McDonalds")   :  circle(2, "solid", "black")
  else if (r["restaurant"]  ==  "Burger King") :  circle(4, "solid", "black")
  else if (r["restaurant"]  ==  "Wendy's")     :  circle(6, "solid", "black")
  else if (r["restaurant"]  ==  "Five Guys")   :  circle(8, "solid", "black")
  else if (r["restaurant"]  ==  "Dairy Queen") :  circle(10,"solid", "black")
  end
end

# Use animal-img to make an image-scatter-plot
# image-scatter-plot(fast-food, "fries", "price", restaurant-img)

##################################
# Define some rows
mcdonalds  = row-n(fast-food, 0)
in-n-out   = row-n(fast-food, 5)

##################################
# Similarity Functions
# simple-similarity   :: Table, String, List<String> -> Table
# distance-similarity :: Table, String, List<String> -> Table
# angle-similarity    :: Table, String, List<String> -> Table
# cosine-similarity   :: Table, String, List<String> -> Table