use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")

# Load your spreadsheet
shelter-sheet = load-spreadsheet( "https://docs.google.com/spreadsheets/d/1VeR2_bhpLvnRUZslmCAcSRKfZWs_5RNVujtZgEl6umA/")

# load the 'animals' sheet as a table
animals-table = load-table: name, species, sex, age, fixed, legs, pounds, weeks
  source: shelter-sheet.sheet-by-name("pets", true)
end

########################################################
# Define some rows
cat-row       =   row-n(animals-table,  0)
dog-row       =   row-n(animals-table, 10)
lizard-row    =   row-n(animals-table, 22)
rabbit-row    =   row-n(animals-table, 24)
young-row     =   row-n(animals-table,  8)
old-row       =   row-n(animals-table,  4)
fixed-row     =   row-n(animals-table,  3)
unfixed-row   =   row-n(animals-table,  0)
female-row    =   row-n(animals-table,  2)
male-row      =   row-n(animals-table,  9)
hermaphrodite-row=row-n(animals-table,  6)

########################################################
# Define some helper functions

# species-dot :: (r :: Row) -> Image
examples:
  species-dot(dog-row)      is square(5, "solid", "black")
  species-dot(cat-row)      is square(5, "solid", "orange")
  species-dot(rabbit-row)   is square(5, "solid", "pink")
  species-dot(lizard-row)   is square(5, "solid", "green")
end
fun species-dot(r):
  if      (r["species"] == "dog"):       square(5, "solid", "black")
  else if (r["species"] == "cat"):       square(5, "solid", "orange")
  else if (r["species"] == "rabbit"):    square(5, "solid", "pink")
  else if (r["species"] == "tarantula"): square(5, "solid", "red")
  else if (r["species"] == "lizard"):    square(5, "solid", "green")
  else if (r["species"] == "snail"):     square(5, "solid", "blue")
  end
end

# regular displays
scatter-plot(animals-table, "name", "pounds", "weeks")
histogram(animals-table, "name", "pounds", 5)

# advanced displays
image-scatter-plot(animals-table, "pounds", "weeks", species-dot)
image-histogram(animals-table, "pounds", 5, species-dot)
