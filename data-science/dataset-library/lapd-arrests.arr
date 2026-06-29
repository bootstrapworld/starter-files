use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")


# Load your spreadsheet and define your table
arrests-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/16jxrKjEFDVvhnjdZuxgTf4gpvrS5gP6_OnwvnprdRTM/edit#gid=159057187-WTwOjE")

arrests-table = load-table:
  id,       # identifier column (unique number for each row)
  kind,     # Kind of arrest
  released, # was the suspect Released?
  sex,      # Sex of the person arrested
  race,     # Race of the person arrested
  age,      # Age of the person arrested
  year,     # Year arrest took place
  month,    # Month arrest took place (1-12)
  day,      # Day arrest took place (1-31)
  hr-24,    # Hour arrest took place (1-24)
  area,     # Neighborood arrest took place
  lat, long # Coordinates (Latitude and Longitude) of arrest location
  source: arrests-sheet.sheet-by-name("LAPD Arrests 2010 - 2019", true)
end

#########################################################
# Define some rows
hollywood-1-11-10 = row-n(arrests-table, 11)




#########################################################
# Define some helper functions





#########################################################
# Define random and logical subsets