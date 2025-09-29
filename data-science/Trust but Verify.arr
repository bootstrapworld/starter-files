use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")

# include our helpful mystery functions
include url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/trust-but-verify-library.arr")

# import our spreadsheet and table
shelter-sheet = load-spreadsheet("19m1bUCQo3fCzmSEmWMjTfnmsNIMqiByLytHE0JYtnQM")
animals-table = load-table: name, species, gender, age, fixed, legs, pounds, weeks
  source: shelter-sheet.sheet-by-name("pets", true)
end

#########################################
# Part 1

# ADD NAMES OF ANIMALS TO THE LIST BELOW, TO DEFINE YOUR SAMPLE TABLE
verify1 = subset-from-names([list: "Sasha", "Wade"])

# Functions to test:
#fixed-catsA(verify1)
#fixed-catsB(verify1)
#fixed-catsC(verify1)

#########################################
# Part 2

# ADD NAMES OF ANIMALS TO THE LIST BELOW, TO DEFINE YOUR SAMPLE TABLE
verify2 = subset-from-names([list: "Sasha", "Wade","Midnight"])
#old-dogs-nametagsA(verify2)
#old-dogs-nametagsB(verify2)
#old-dogs-nametagsC(verify2)