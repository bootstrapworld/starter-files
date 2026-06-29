use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
election-2018-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1L7hf0llI8dl8okVuat2fa1K4lqD5O301IFPi81vG7fc/")

election-table = load-table:
  state,            # name of State
  population,       # Population of state
  percent-turnout,  # Percentage of population who turned out to vote in 2018
  percent-vote-dem, # Percentage of vote that went to Democrats
  percent-vote-rep, # Percentage of vote that went to Republicans
  total-seats,      # Total number of congressional seats
  seats-dem,        # Total number of congressional seats that went to Democrats
  seats-rep,        # Total number of congressional seats that went to Republicans
  percent-seats-dem,# Percentage of congressional seats that went to Democrats
  percent-seats-rep,# Percentage of congressional seats that went to Republicans
  winning-party,    # Which party won the most seats?
  seats-match-vote  # Does the % seats won by each party match the % voters in each party?
  source: election-2018-sheet.sheet-by-name("Sheet1", true)
end


#########################################################
# Define some rows



#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


