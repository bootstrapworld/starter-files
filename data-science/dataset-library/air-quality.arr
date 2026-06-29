use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")


# Load your spreadsheet and define your table
air-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1IWfFqS3Lrpj43rH1BwXeUmNm452rlU9_n07bWpxpv9U")

air-table = load-table:
  state,           # name of State
  county,          # name of County
  state-county,    # unique ID (state+county)
  aqi,             # Air Quality Index
  income,          # Median Income
  pop,             # Population
  urban,           # is the county Urban?
  rural,           # is the county Rural?
  metro,           # is the county Metropolitan (suburban)?
  code,            # Rural-Urban Continuum Code (1-10)
  pct-white,       # % of the county that is white
  pct-other,       # % of the county that is non-white
  pct-asthma,      # % of the county diagnosed with asthma
  pct-cancer,      # % of the county diagnosed with cancer
  cancer-outlook,  # projected cancer diagnoses (e.g. - rising, falling, etc)
  pp,              # total number of Power Plants
  main-power,      # Main type of Power
  co2,             # tons of CO2 emissions from power plants
  commute,         # mean Commute time
  life-expt,       # median life expectancy
  industry,        # main Industry (by # of employees)
  pct-ag,          # % employed in agricultural sector
  pct-extr,        # % employed in energy extraction sector
  pct-t,           # % employed in transportation and warehousing
  interstate       # is there an Interstate highway
  source: air-sheet.sheet-by-name("Air Quality and Related Data by US County", true)
end

# aqi = air quality index (0 to 50 is excellent. >200 is very unhealthy.)
# pp = number of power plants
# pct-ag (agriculture, forestry & fishing), pct-extr (gas/oil extraction, mining & quarrying), pct-t (transportation & warehousing) are the percent of total industries from these sectors.
# code = rural-urban continuum code (1-9, with 1 being highest pop.)

#########################################################
# Define some rows
santa-fe-nm    = row-n(air-table, 519)
florida-county = row-n(air-table, 160)



#########################################################
# Define some helper functions

# is-FL :: (r :: Row) -> Boolean
fun is-FL(r): r["state"] == "Florida" end


#########################################################
# Define random and logical subsets

