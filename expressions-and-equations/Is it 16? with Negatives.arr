use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations", "../libraries/core.arr")

########### Section 1 ###########################


examples:

  expt(-2, 4) == 16                is true

  negate(2 * 2 * expt(2, 2)) == 16 is true

  (expt(-2, 3) + 8) == 16          is true

  (expt(-4, 2) * negate(2)) == 16  is true

  (4 * expt(negate(1), 4)) == 16   is true

  ((expt(-4, 3) / 2) / -2) == 16   is true

  (-2 * expt(-2, 3)) == 16         is true

  ((expt(-4, 3) / -2) / 2) == 16   is true

end

########### Section 2 ###########################

examples:

  num-expt(-6, 2) - 11 is 25

end