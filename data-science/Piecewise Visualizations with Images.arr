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


#########################################################
# Some images to use, scaled to useful sizes
dog-img    = scale(0.3, image-url("https://www.bootstrapworld.org/clipart/Animals/dog.png"))
cat-img    = scale(0.3, image-url("https://www.bootstrapworld.org/clipart/Animals/cat.png"))
rabbit-img = scale(0.3, image-url("https://www.bootstrapworld.org/clipart/Animals/rabbit.png"))
lizard-img = scale(0.3, image-url("https://www.bootstrapworld.org/clipart/Animals/lizard.png"))
spider-img = scale(0.3, image-url("https://www.bootstrapworld.org/clipart/Animals/spider.png"))
snail-img  = scale(0.3, image-url("https://www.bootstrapworld.org/clipart/Animals/snail.png"))

#########################################################
# Define some helper functions

# animal-img :: (r :: Row) -> Image
fun animal-img(r):
  if      (r["species"] == "dog"):       dog-img
  else if (r["species"] == "cat"):       cat-img
  else if (r["species"] == "rabbit"):    rabbit-img
  else if (r["species"] == "tarantula"): spider-img
  else if (r["species"] == "lizard"):    lizard-img
  else if (r["species"] == "snail"):     snail-img
  end
end

##########################################################
# make the scatter plots!

scatter-plot(animals-table, "name", "age", "weeks")
image-scatter-plot(animals-table, "age", "weeks", animal-img)
