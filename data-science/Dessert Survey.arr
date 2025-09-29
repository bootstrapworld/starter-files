use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")

# Load your spreadsheet
dessert-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1hdv8Zbzskq93C5YzTSEQWrGWcrDA_h9eRoflSsiz00k")

# load the 'dessert' sheet as a table
dessert-table = load-table: id, dessert, gender-id, age
  source: dessert-sheet.sheet-by-name("eighth-grade-survey-results", true)
end
