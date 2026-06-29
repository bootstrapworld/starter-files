use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")


#########################################################
# Load your spreadsheet
colleges-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1_gUN2vm1q3ifckJhah6TKllJuDwsnWcMTwJUcp2SaxA")

# Load sheet "Colleges in the US (2019-2020)" as a table. Describe columns in comments.
colleges-table = load-table:
  school, city, state,
  geography,    # rural/town/suburb/city by size
  region,       # e.g. southeast, plains, Great Lakes, far west, etc.
  control,      # public, private non-profit, private for-profit
  program,      # 2-year, 4-year, only graduate
  deg,          # highest degree offered
  gender,       # all, men, women
  operating,    # returns true if college was operating as of Aug 3, 2021
  main-campus,  #
  hbcu,         # returns true if it's a Historically Black College or University
  indigenous,   #
  svc,          # returns true if it's a US Service Academy (military, navy, etc.)
  SAT-range,    # averages of combined SAT and ACT scores lie within this range
  pop,          # undergraduate population
  accept,       # acceptance rate - values of 1 indicate virtually 100% acceptance
  pt,           # % of undergrads studying part-time
  fac,          # monthly faculty salary
  in, out,      # in-state tuition, out-of-state tuition
  pct-pell,     # % who've received Federal Pell Grants - awarded based on financial need
  avg-cost,     # average cost of attendance, including room & board
  avg-net-price # average price a student pays after all financial aid
  source: colleges-sheet.sheet-by-name("Colleges in the US (2019-2020)", true)
end

#########################################################
# Define some rows
alabama-am-univ = row-n(colleges-table, 0)
brown-univ = row-n(colleges-table, 2160)


#########################################################
# Define some helper functions
fun low-accept(r :: Row) -> Boolean:
  (r["acceptance-rate"] < 0.2)
end

fun ne(r :: Row) -> Boolean:
  (r["region"] == "New England")
end

fun operating-hbcu(r :: Row) -> Boolean:
  ((r["operating"] == true) and
    (r["hbcu"] == true))
end



#########################################################
# Define random and logical subsets
