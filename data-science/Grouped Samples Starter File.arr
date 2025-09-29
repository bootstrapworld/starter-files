use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")

# Load your spreadsheet and define your table
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

# NOTE: examples have been *intentionally removed* from
# these functions. If you define your own functions,
# be sure to always include examples!

# is-old :: (r :: Row) -> Boolean
# consumes a row and asks if age > 10
fun is-old(r): r["age"] > 10 end

# is-young :: (r :: Row) -> Boolean
# consumes a row and asks if age <= 1
fun is-young(r): r["age"] <= 1 end

# is-dog :: (r :: Row) -> Boolean
# consumes a row and asks if the species is "dog"
fun is-dog(r): r["species"] == "dog" end

# is-cat :: (r :: Row) -> Boolean
# consumes a row and asks if the species is "cat"
fun is-cat(r): r["species"] == "cat" end

# is-female :: (r :: Row) -> Boolean
# consumes a row and asks if the sex is "female"
fun is-female(r): r["sex"] == "female" end

# is-fixed :: (r :: Row) -> Boolean
# consumes a row and looks up the value in the fixed column
fun is-fixed(r): r["fixed"] end

# name-has-s :: (r :: Row) -> Boolean
# consumes a row and asks if the name contains "s"
fun name-has-s(r): string-contains(r["name"], "s") end

########################################################
# Define some grouped samples

# 1) a table of kittens
kittens = filter(filter(animals-table, is-cat), is-young)

# 2) a table of puppies

# 3) a table of fixed cats

# 4) a table of cats with "s" in their names

# 5) a table of old dogs

# 6) a table of fixed animals

# 7) a table of old, female cats

# 8) a table of fixed kittens

# 9) a table of fixed, female dogs

# 10) a table of old, fixed, female cats