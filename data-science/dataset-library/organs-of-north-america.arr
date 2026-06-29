use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
organs-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1IlR9rvo4gQzcynhj4rjf_6mm2gwt5bl34j-__PgL7L0/")

organs-table = load-table:
  organ-id,      # ID (unique for each row)
  state,         # state where the organ can be found
  venue,         # where is the organ located?
  builder,       # company that created the organ
  ranks,         # number of ranks
  stops,         # number of stops
  manuals,       # number of manuals
  lowest-pitch,  # lowest pitch the organ can make
  year,          # year organ was built
  altered        # has the organ been altered since construction?
  source: organs-sheet.sheet-by-name("Pipe-Organs", true)
end

#################################################
# Define some rows

# The largest organ in the world
wanamaker = row-n(organs-table, 0)

# The organ in Sayles Hall at Brown University
sayles = row-n(organs-table, 3)



#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets

