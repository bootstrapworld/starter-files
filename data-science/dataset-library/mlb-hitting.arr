use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
mlb-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1svCf5aGzV6wdrJBdA30ZGgIxm2jNgLOs72MoukacpBE/edit#gid=1290967886")

mlb-table = load-table:
  team,    # name of team
  league,  # which league (AL or NL?)
  state,   # state the team is based in
  region,  # SW, MW, NW, SE, etc...
  games,   # number of games played
  AB,      # total At Bats (trips to the plate)
  R,       # total Runs
  H,       # total Hits
  second-base, # total number of times a runner reaches 2nd base
  third-base,  # total number of times a runner reaches 3rd base
  HR,      # total Home Runs
  RBI,     # total Runs Batted In
  BB,      # total Walks
  SO,      # total StrikeOuts
  SB,      # total Stolen Bases
  CS,      # total time Caught Stealing
  AVG,     # overall batting average
  OBP,     # overall On Base Percentage
  SLG,     # overall Slugging Percentage
  OPS,     # On Base + Slugging (the sum of the previous two columns)
  IBB,     # total Intentional Walks
  HBP,     # total times Hit By Pitch
  SAC,     # total Sacrifice Bunts
  SF,      # total Sacrifice Fly balls
  TB,      # total bases
  XBH,     # total Extra Base Hits
  GDP,     # total Ground balls resuling in Double Plays
  GO,      # total Ground Outs
  AO,      # total Air Outs
  GO-AO,   # Ground Out to Air Out ratio
  NP,      # total Number of Pitches
  PA,      # total Plate Appearances
  salary   # total Salary
  source: mlb-sheet.sheet-by-name("2019", true)
end



#########################################################
# Define some rows
rockies = row-n(mlb-table, 8)






#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


