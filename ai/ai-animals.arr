use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")

# Load your spreadsheet and define your table

shelter-sheet = load-spreadsheet(
"https://docs.google.com/spreadsheets/d/1VeR2_bhpLvnRUZslmCAcSRKfZWs_5RNVujtZgEl6umA/")

# load the 'animals' sheet as a table
animals-table = 
  load-table: name, species, sex, age, fixed, legs, pounds, weeks
  source: shelter-sheet.sheet-by-name("pets", true)
end


########################################################
# Define some rows
cat-row = row-n(animals-table, 0) 
dog-row = row-n(animals-table, 10) 

# Make scatter plots showing the relationships
# between pounds v. weeks and age v. weeks
scatter-plot(animals-table, "name", "pounds", "weeks")
scatter-plot(animals-table, "name", "age", "weeks")

fun pounds-predictor(pounds): (... * pounds) + ... end
fun   age-predictor(age):     (... *  age  ) + ... end

# Once you've filled in the blanks above, uncomment these lines of code to fit your models!
# fit-model(animals-table, "name", "pounds", "weeks", pounds-predictor)
# fit-model(animals-table, "name", "age", "weeks", pounds-predictor)
