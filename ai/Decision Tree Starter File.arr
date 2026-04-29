use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")
shelter-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1DjY_8v8VGyacnpuy72Up4oYYIJ64gqvoCKR7_LTf3lI/")
simple-animals = 
  load-table: name, species, sex, tail, mammal, swims
    source: shelter-sheet.sheet-by-name("simple", true)
end

# c1 = build-tree(simple-animals, [list: "tail", "sex"], "species", 1)
# classify(simple-animals, c1)
# confusion-matrix(simple-animals, "species", c1)


# c2 = build-tree(more-animals, [list: "mammal", "swims"], "species", 2)
# classify(simple-animals, c2)
# confusion-matrix(simple-animals, "species", c2)

