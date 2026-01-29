use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
premiums-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/115qicZWalDztV4Y5GO8lLUIvFkqgGoc2JgeOpwwLcYU/edit?gid=0#gid=0")


# load the 'performance' sheet as a table
premiums-table = 
  load-table: driver-age, experience, num-accidents, annual-mileage, car-age, premium
    source: premiums-sheet.sheet-by-name("Sheet1", true)
end


# lr-plot(premiums-table, "driver-age", "driver-age", "premium")

# lr-plot(premiums-table, "driver-age", "experience", "premium")

# lr-plot(premiums-table, "driver-age", "num-accidents", "premium")

# lr-plot(premiums-table, "driver-age", "annual-mileage", "premium")

# lr-plot(premiums-table, "driver-age", "car-age", "premium")

lr-plot(premiums-table, "driver-age", "driver-age", "num-accidents")
