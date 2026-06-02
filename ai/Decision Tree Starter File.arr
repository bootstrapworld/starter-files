use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")

shelter-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1DjY_8v8VGyacnpuy72Up4oYYIJ64gqvoCKR7_LTf3lI/")

training = 
  load-table: ID, species, sex, pounds, tail, mammal, swims
    source: shelter-sheet.sheet-by-name("training", true)
  end

testing = 
  load-table: ID, species, sex, pounds, tail, mammal, swims
    source: shelter-sheet.sheet-by-name("testing", true)
  end

#####################################################################
# define firepaw to be the first row in the table
firepaw = row-n(training, 0)

# define frisky to be the sixth row in the table


#####################################################################
# tail-classifier :: Row -> String
# consumes an animal, and predicts the species
fun tail-classifier(r):
  if r["tail"] == true:
    "cat"
  else: 
    "snail"
  end
end

# You can test out any classifier function using the `classify` function
# classify(testing, "species", tail-classifier)

#####################################################################
# animal-img :: Row -> Image
# given a row from the animals table, produce an emoji of that species

fun animal-img(r): 
  if      (r["species"] == "dog"):       text("🐶", 20, "black")
  else if (r["species"] == "cat"):       text("😺", 20, "black")
  else if (r["species"] == "lizard"):    text("🦎", 20, "black")
  else if (r["species"] == "rabbit"):    text("🐇", 20, "black")
  else if (r["species"] == "snail"):     text("🐌", 20, "black")
  else if (r["species"] == "tarantula"): text("🕷️", 20, "black")
  end
end

# Use animal-img to make an image-dot-plot
# image-dot-plot(training, "pounds", animal-img)

#####################################################################
# Define some more classifier functions!

# my-classifier1 :: Row -> String
# fill in the `...` with your splits and leaf nodes for a one-level tree!
fun my-classifier1(r):
  if r[...] == ... :
    ...
  else: 
    ...
  end
end

# fill in the `...` with your splits and leaf nodes for a two-level tree!
fun my-classifier2(r):
  if r[...] == ... :
    if r[...] == ... :
      ...
    else: 
      ...
    end

  else: 
    if r[...] == ... :
      ...
    else: 
      ...
    end
  end
end