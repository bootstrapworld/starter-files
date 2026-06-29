use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
art-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/108ZnfCy3V2WkpSmjYpane6gmogM3EtBLL1sD-9h0Acc")

art-table = load-table:
  title,              # title of work
  artist,             # name of Artist
  sex,                # Sex of artist
  medium,             # materials used
  location,           # Location(s) of exhibition
  num-locations,      # Number of Locations
  price,              # Price of the work
  why-included        # Why the work was included
  source: art-sheet.sheet-by-name("Art", true)
end


#########################################################
# Define some rows
first-painting = row-n(art-table, 0)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


