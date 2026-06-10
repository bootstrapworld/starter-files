use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations", "../libraries/core.arr")

########### Section A ###########################

examples "A":
  
  expt(2, 4)           == 16 is true
  (expt(2, 3) + 10)    == 16 is true
  (4 * expt(1, 4))     == 16 is true
  (2 * expt(2, 3))     == 16 is true
  (2 * 2 * expt(2, 2)) == 16 is true
  (expt(4, 2) * 2)     == 16 is true
  (expt(4, 3) / 2 / 2) == 16 is true
  (expt(4, 3) / 2 / 2) == 16 is true

end


########### Section B ###########################

examples "B":
  
  (expt(6, 2) - 11) == 25 is true

end