use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
pokemon-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1_1bRpw5I-wOnXaQrCyaQGhvSwCWpZciFHnwExfi04qU")

pokemon-table = load-table:
  number,         # ID (unique for each row)
  name,           # name
  type1,          # primary Type
  type2,          # secondary Type
  total,          # Total points
  hp,             # Hit points
  attack,         # Attack points
  defense,        # Defense points
  special-attack, # Special Attack points
  special-defense,# Special Defense points
  speed,          # Speed
  generation,	    # pokemon Generation
  legendary,      # Legendary status
  region,         # Region
  tier            # Tier
  source: pokemon-sheet.sheet-by-name("2022", true)
end




#########################################################
# Define some rows
charizard = row-n(pokemon-table, 6)







#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


