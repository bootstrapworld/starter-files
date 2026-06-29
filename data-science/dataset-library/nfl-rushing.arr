use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
nfl-rushing-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1o8d0k46L8mkIIIpgYHXtMLxDzjXE6l1epN5tWLHyG6o/edit#gid=121200543")

rush-table = load-table:
  rank,     # player Rank
  player,   # Player name
  team,     # Team abbreviation (by city)
  age,      # player Age
  position, # player position
  played,   # number of games Played
  started,  # number of games Started
  attempts, # number of rushing Attempts
  yards,    # number of Yards rushed
  td,       # rushes ending in TouchDowns
  first-downs, # rushes completing First Downs
  longest,  # Longest single rush
  yards-avg,# Yards Averaged across all rushes
  yards-game,# Yards arveraged across all Games
  fumbles   # total number of Fumbles
  source: nfl-rushing-sheet.sheet-by-name("NFL Rushing 2019", true)
end


#########################################################
# Define some rows
top-ranked = row-n(rush-table, 0)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


