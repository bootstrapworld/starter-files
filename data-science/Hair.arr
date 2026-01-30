use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")

# Load your spreadsheet and define your table
hair-sheet = load-spreadsheet(
"https://docs.google.com/spreadsheets/d/1I1TtM65USQxad4m9kDu8XAjUD2h4IAOTxzZl2rXE9cA/")

# load the 'hair' sheet as a table
hair-table = load-table: hair-color, number-of-students
  source: hair-sheet.sheet-by-name("Sheet1", true)
end

########################################################

# pie-chart-summarized :: Table, String, String -> Image
# bar-chart-summarized :: Table, String, String -> Image
