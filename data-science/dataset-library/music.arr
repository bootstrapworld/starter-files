use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
music-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/13OFoNwVJZiKr1fWjKO912lr2RXxUiCakNJmeZT4JzHE")

music-table = load-table:
  artist,               # name of Artist
  song,                 # name of Song
  duration,             # Duration (in minutes)
  relative-duration,    # Relative Duration (short, long, etc)
  loudness,             # How loud is the song?
  relative-loudness,    # Relative loudness (loud, quiet, etc)
  bpm,                  # Beats Per Minute
  relative-speed,       # Relative speed (fast, moderate, etc)
  end-of-fade-in,       # End of fade-in (seconds)
  start-of-fade-out,    # Start of fade-out (seconds)
  familiarity,          # how much the song resembles others (0-1)
  buzz,                 # popularity of song (0-1)
  terms                 # descriptive Terms for the song (hip hop, jazz, etc)
  source: music-sheet.sheet-by-name("2019", true)
end




#########################################################
# Define some rows
angie = row-n(music-table, 0)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


