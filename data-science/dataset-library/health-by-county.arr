use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")


# Load your spreadsheet and define your table
health-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1gnczXHXpg7cuYQ-mQ1jDhMPoFAvz7IeBAzfpGu-fotc/")

health-table = load-table:
  id,                  # ID (unique per row)
  county,              # county name
  state,               # state name
  pct-nh,              # % not health
  avg-pud,             # avg number of physically unhealthy days/yr
  avg-mud,             # avg number of mentally unhealthy days/yr
  pct-smoke,           # % population that smokes
  pct-alc,             # % population that drinks excessively
  pct-obese,           # % population whose BMI rates an Obesity diagnosis
  pct-inactive,        # % population physically inactive
  pct-unins,           # % population that is uninsured
  pct-hs-grad,         # % population that finished HS
  pct-some-college,    # % population that attended some college
  pct-unemp,           # % population that is unemployed
  pct-child-pov,       # % children living in poverty
  inc-80,              # income made by the 80th percentile
  inc-20,              # income made by the 20th percentile
  income-ineq,         # income inequality
  pct-sp,              # % children living in single-parent household
  h20-v,               # is there a water violation in this county?
  pct-hp,              # % severe housing problems
  pct-lda,             # % long commute driving alone
  pct-nonwhite         # % non-white residents
  source: health-sheet.sheet-by-name("County Health",
      true)
end

#########################################################
# Define some rows
cherokee = row-n(health-table, 9)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets

