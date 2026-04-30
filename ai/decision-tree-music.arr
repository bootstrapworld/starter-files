use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")
music-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1iQpfRr3aN4HErX73B66EKszMAMdmquWfamR7q_9cT4c/")
music-testing = 
  load-table: 
    duration_ms, 
    popularity, 
    danceability, 
    energy, 
    key, 
    loudness, 
    mode, 
    speechiness, 
    acousticness, 
    liveness, 
    valence, 
    tempo, 
    time_signature
    source: music-sheet.sheet-by-name("training", true)
end

music-testing = 
  load-table: 
    duration_ms, 
    popularity, 
    danceability, 
    energy, 
    key, 
    loudness, 
    mode, 
    speechiness, 
    acousticness, 
    liveness, 
    valence, 
    tempo, 
    time_signature
    source: music-sheet.sheet-by-name("testing", true)
end

# images of various species
country-img = text("🐴, 20, "black")
rock-img    = text("🎸, 20, "black")
rnb-img     = text("🎤", 20, "black")


######################################################################
# animal-img :: Row -> Image
# given a row from the animals table, produce an image of that species
fun song-img(r): 
  if      (r["genre"] == "country"):     country-img
  else if (r["genre"] == "rock-n-roll"): rock-img
  else if (r["genre"] == "r-n-b"):       rnb-img
  end
end

