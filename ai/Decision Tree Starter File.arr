use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")
shelter-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1DjY_8v8VGyacnpuy72Up4oYYIJ64gqvoCKR7_LTf3lI/")
simple-animals = 
  load-table: name, species, sex, age, fixed, legs, pounds, long-tail, no-fur, weeks
    source: shelter-sheet.sheet-by-name("simple", true)
end

# c1 = build-tree(simple-animals, [list: "age", "pounds"], "species", 1)
# classify(simple-animals, c1)
# confusion-matrix(simple-animals, "species", c1)

more-animals = 
  load-table: name, species, sex, age, fixed, legs, pounds, long-tail, no-fur, weeks
    source: shelter-sheet.sheet-by-name("pets", true)
end

# c2 = build-tree(more-animals, [list: "age", "pounds"], "species", 2)
# classify(simple-animals, c2)
# confusion-matrix(simple-animals, "species", c2)

