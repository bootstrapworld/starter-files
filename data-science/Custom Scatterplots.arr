use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")


# Load your spreadsheet
shelter-sheet = load-spreadsheet(
"https://docs.google.com/spreadsheets/d/1VeR2_bhpLvnRUZslmCAcSRKfZWs_5RNVujtZgEl6umA/")

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

# age-dot :: Row -> Image
examples:
  age-dot(old-row) is circle(old-row["age"], "solid", "blue")
  age-dot(dog-row) is circle(dog-row["age"], "solid", "blue")
end
fun age-dot(r): circle(r["age"], "solid", "blue") end


# species-tag :: Row -> Image
examples:
  species-tag(old-row) is text(old-row["species"], 15, "red")
  species-tag(dog-row) is text(dog-row["species"], 15, "red")
end
fun species-tag(r): text(r["species"], 15, "red") end


# A scatter-plot, and an image-scatter-plot
scatter-plot(animals-table, "species", "pounds", "weeks")
#image-scatter-plot(animals-table, "pounds", "weeks", age-dot)


