use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
nfl-passing-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1tpHZdUZQ0Fzuy1G1qqPPoKS0p6PkG3hb_P_013kcVIo/")

#Column Title Shorthand
# cmp - passes completed
# att - passes attempted
# pct-int - percentage of times intercepted while attempting to pass

nfl-passing-table = load-table:
  rank,     # player Rank
  player,   # player Name
  team,     # Team played for
  age,      # player Age
  position, # player Position
  probowl,  # did the player appear in the Pro Bowl?
  cmp,      # passes completed
  att,      # passes attempted
  pct-cmp,  # Percent Completions
  yds,      # Yards gained
  td,       # number of TouchDowns
  pct-int,  # Percent of Interceptions while attempting to pass
  yds-adj,  # Adjusted Yards gained
  yds-comp, # Yards gained from Completed passes
  yds-game, # Yards gained per-game
  sacked    # total Sacks
  source: nfl-passing-sheet.sheet-by-name("NFL Passing 2019", true)
end


#########################################################
# Define some rows
top-ranked = row-n(nfl-passing-table, 0)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


