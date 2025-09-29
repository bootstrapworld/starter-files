use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")



#########################################################
# Load your spreadsheet and define your table
olympics-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1Rn4sASAwoIwt0DnwcEgljsvuQk7AKQtnSDhM-E_5MnA")

running-men-table = load-table: Meters, Seconds
  source: olympics-sheet.sheet-by-name("running-men", true)
end


running-women-table = load-table: Meters, Seconds
  source: olympics-sheet.sheet-by-name("running-women", true)
end


swimming-men-table = load-table: Meters, Seconds
  source: olympics-sheet.sheet-by-name("swimming-men", true)
end


swimming-women-table = load-table: Meters, Seconds
  source: olympics-sheet.sheet-by-name("swimming-women", true)
end


skating-men-table = load-table: Meters, Seconds
  source: olympics-sheet.sheet-by-name("skating-men", true)
end


skating-women-table = load-table: Meters, Seconds
  source: olympics-sheet.sheet-by-name("skating-women", true)
end


