use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")
shelter-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1DjY_8v8VGyacnpuy72Up4oYYIJ64gqvoCKR7_LTf3lI/")
simple-animals = 
  load-table: name, species, sex, pounds, tail, mammal, swims
    source: shelter-sheet.sheet-by-name("simple", true)
end


# images of various species
dog-img      = text("🐶", 20, "black")
cat-img      = text("😺", 20, "black")
lizard-img   = text("🦎", 20, "black")
tarantula-img= text("🕷️", 20, "black")
snail-img    = text("🐌", 20, "black")


######################################################################
# animal-img :: Row -> Image
# given a row from the animals table, produce an image of that species
fun animal-img(r): 
  if      (r["species"] == "dog"):       dog-img
  else if (r["species"] == "cat"):       cat-img
  else if (r["species"] == "tarantula"): tarantula-img
  else if (r["species"] == "lizard"):    lizard-img
  else if (r["species"] == "snail"):     snail-img
  end
end

# define firepaw to be the first raw in the table
firepaw = row-n(simple-animals, 0)

######################################################################
# Classifiers

# tail-classifier :: Row -> String
# consumes an animal, and predicts the species
fun tail-classifier(r):
  if r["tail"] == true:
    "cat"
  else: 
    "snail"
  end
end

# my-classifier :: Row -> String
# fill in the `...` with your splits and leaf nodes!
fun my-classifier(r):
  if r[...] == ... :
    ...
  else: 
    ...
  end
end

# You can test out the classifier using the `classify` function
# classify(simple-animals, "species", tail-classifier)

# Use the `confusion-matrix` to see where the classifier got confused
# confusion-matrix(simple-animals, "species", tail-classifier)
