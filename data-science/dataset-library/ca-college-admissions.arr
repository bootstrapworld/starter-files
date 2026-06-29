use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")


# Load your spreadsheet
college-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/16U0kPYf8u-bPWOkF805zGRAYpSnCWbMHFTpWxPvXh7Q")

# Load "Sheet1" as a table
college-table = load-table:
  college-year,  # identifier column - combines college name and enrollment year
  college,       # name of college
  year,          # year of enrollment (e.g. 2020 means students are freshman in 2020)
  adm-rate,      # admission rate
  pre,           # primary race enrolled
  pct-pre,       # % primary race enrolled
  pct-white,     # % white
  pct-asian,     # % Asian
  pct-blna,      # % Black, Latinx, or Native American
  avg-gpa,       # average grade point average
  pct-in-state,  # % of in-state enrollees
  uc,            # true if the school is part of the Univ of California system
  weighted       # weighted GPA - honors/AP classes get an extra point,  bumping up the grade point percentage (an A becomes a 5.0, B becomes 4.0 etc.)
  source: college-sheet.sheet-by-name("Sheet1", true)
end

#########################################################
# Define some rows
ucla-2006 = row-n(college-table, 100)
ucd-2018 = row-n(college-table, 37)

#########################################################
# Define some helper functions

fun is-uc(r):
  r["uc"]
end

fun is-not-uc(r):
  not(is-uc(r))
end





#########################################################
# Define random and logical subsets

