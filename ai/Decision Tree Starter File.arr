use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")
shelter-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1DjY_8v8VGyacnpuy72Up4oYYIJ64gqvoCKR7_LTf3lI/")
simple-animals = 
  load-table: name, species, sex, pounds, tail, mammal, swims
    source: shelter-sheet.sheet-by-name("simple", true)
  end

#####################################################################
# images of various species
dog-img      = text("🐶", 20, "black")
cat-img      = text("😺", 20, "black")
lizard-img   = text("🦎", 20, "black")
tarantula-img= text("🕷️", 20, "black")
snail-img    = text("🐌", 20, "black")

# define firepaw to be the first raw in the table
firepaw = row-n(simple-animals, 0)


#######################################################################
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


# tail-classifier :: Row -> String
# consumes an animal, and predicts the species
fun tail-classifier(r):
  if r["tail"] == true:
    "cat"
  else: 
    "snail"
  end
end

fun swim-classifier(r):
  if r["swims"] == true:
     "dog"
  else:
     "cat"
  end
end

# You can test out the classifier using the `classify` function
# classify(simple-animals, "species", tail-classifier)


# my-classifier1 :: Row -> String
# fill in the `...` with your splits and leaf nodes!
fun my-classifier1(r):
  if r[...] == ... :
    ...
  else: 
    ...
  end
end

# fill in the `...` with your splits and leaf nodes!
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



# Use the `confusion-matrix` to see where the classifier got confused
# confusion-matrix(simple-animals, "species", tail-classifier)


# c1 = build-tree(simple-animals, [list: "tail", "sex"], "species", 1)
# classify(simple-animals, c1)
# confusion-matrix(simple-animals, "species", c1)


# c2 = build-tree(more-animals, [list: "mammal", "swims"], "species", 2)
# classify(simple-animals, c2)
# confusion-matrix(simple-animals, "species", c2)

