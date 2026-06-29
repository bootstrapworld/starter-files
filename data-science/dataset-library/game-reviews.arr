use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")



#########################################################
# Load your spreadsheet and define your table
reviews-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1Ss221kjz2WJUsTlxK7TcnsXLPoSbnfUKv-JP8gCiGRw")

reviews-table = load-table:
  title,            # Title of game
  playstation,      # available on PlayStation?
  xbox,             # available on XBox?
  nintendo,         # available on Nintendo?
  pc,               # available on PC?
  other,            # available on Other platforms?
  score,            # review score
  genre,            # kind of game
  editors-choice,   # did the game with Editors Choice?
  release-year,     # Year game was Released
  release-month     # Month game was Released (1-12)
  source: reviews-sheet.sheet-by-name("2019",
      true)
end


#########################################################
# Define some rows
iconoclasts = row-n(reviews-table, 89)







#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


