use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")


# Load your spreadsheet and define your table
nba-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1C-LqFhkbI5eUKEGGWNXPseA824wCIbAH-Ik9chl9e6I")

nba-table = load-table:
  id,
  name,       # player Name
  was-traded, # Was the player Traded?
  team,       # Team name
  pos,        # Position
  age,        # plater Age
  gp,         # Games Played
  mppg,       # Minutes Played Per Game
  fta,        # Free Throws Attempted
  ft-pct,     # Free Throw Percentage
  tpa,        # Two Point shots Attempted
  twp-pct,    # Two Point shots Percentage
  thpa,       # Three Point shots Percentage
  thp-pct,    # Three Point shots Percentage
  efg-pct,    # efg-pct = effective field goal percentage
  ts-pct,     # ts-pct = true shooting percentage
  ht
  source: nba-sheet.sheet-by-name("NBA Players 2018-2019", true)
end

#NOTES ON COLUMN TITLE ABBREVIATIONS


# fta =
# ft-pct = free throw percentage
# twpa/tp-pct = two point shots attempted/percentage
#thpa/thp-pct = three point shots attempted/percentage




#########################################################
# Define some rows
Alex-Abrines = nba-table.row-n(0)




#########################################################
# Define some helper functions





#########################################################
# Define random and logical subsets