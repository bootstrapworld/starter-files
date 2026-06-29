use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
occupation-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1fAzyoVgtSMl9ja-JMpou_Y5RRyoTOPh2umR_mkJYQyU")

occupation-table = load-table:
  occupation,       # job title
  occupation-type,  # type of job
  tot-employment,   # Total number of Employees doing that job
  pct-non-white,    # Percentage of non-white people doing this job
  pct-female,       # Percentage of females doing this job
  educ-req,         # Education Requirements for this job
  amw,              # Annual Median Wage
  wmw,              # Weekly Median Wage
  female-wmw        # Female Weekly Median Wage
  source: occupation-sheet.sheet-by-name("US Jobs 2019", true)
end

#########################################################
# Define some rows
comp-programmers = row-n(occupation-table, 28)


#########################################################
# Define some helper functions


#########################################################
# Define random and logical subsets
