use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet
majors-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1wIpbDIBQMjAwaLGNK-e5snmzui0DuWFdrkoSNVv9m5c/")

# Load the "Majors" sheet as a table
majors-table = load-table: major, category, men, women, more-men-than-women, employed, unemployed, income
  source: majors-sheet.sheet-by-name("Majors", true)
end

#########################################################
# Define some rows
computer-engineering = row-n(majors-table, 36)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets