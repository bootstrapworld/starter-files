use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
esports-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1SqK3BP-RKrN9adFQz2XvZUMHCAPsm530XT1hC96L6w0/")

esports-table = load-table:
  game,             # name of Game
  release-date,     # date game was Released
  release-era,      # era ("pre-2000", "post-2010", etc)
  genre,            # kind of game
  total-earnings,   # total earnings at in-person+virtual tournaments
  online-earnings,  # total earnings at virtual tournaments
  winners,          # number of tournament winners
  tournaments       # number of tournaments
  source: esports-sheet.sheet-by-name("esports",
      true)
end


#########################################################
# Define some rows
csgo = row-n(esports-table, 81)
lol = row-n(esports-table, 164)
fortnite = row-n(esports-table, 492)



#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets



