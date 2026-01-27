import csv as csv
#########################################################
# Load your spreadsheet and define your table
music-url = "https://docs.google.com/spreadsheets/d/13OFoNwVJZiKr1fWjKO912lr2RXxUiCakNJmeZT4JzHE/export?gid=117998921&format=csv"

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
  source: csv.csv-table-url(music-url, {
    header-row: true,
    infer-content: true
  })
end




######################################################### 
# Define some rows
angie = row-n(music-table, 0)




######################################################### 
# Define some helper functions
GENRES = [list: "rap", "country"]
fun is-genre(r): GENRES.member(r["terms"]) end

fun genre-color(r):
  
end


######################################################### 
# Define random and logical subsets

genre-table = filter(music-table, is-genre)
.
