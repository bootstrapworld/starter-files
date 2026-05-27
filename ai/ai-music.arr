use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")

music-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1iQpfRr3aN4HErX73B66EKszMAMdmquWfamR7q_9cT4c/")

# a function that takes in the name of a sheet, and loads the table from that sheet
fun load-music-sheet(sheet-name):
  load-table: 
    ID,
    artist,
    duration_ms, 
    popularity, 
    danceability, 
    energy, 
    loudness, 
    speechiness, 
    acousticness, 
    liveness, 
    tempo, 
    genre
    source: music-sheet.sheet-by-name(sheet-name, true)  
  end
end

# load our training and testing datasets
music-training = load-music-sheet("training")
music-testing  = load-music-sheet("testing")

######################################################################
# genre-img :: Row -> Image
# given a row from the table, produce an emoji representing the song's genre

fun genre-img(r): 
  if      (r["genre"] == "country"):     text("🐴", 20, "black")
  else if (r["genre"] == "rock-n-roll"): text("🎸", 20, "black")
  else if (r["genre"] == "r-n-b"):       text("🎤", 20, "black")
  else if (r["genre"] == "reggae"):      text("🇯🇲", 20, "black")
  else if (r["genre"] == "k-pop"):       text("🇰🇷", 20, "black")
  end
end