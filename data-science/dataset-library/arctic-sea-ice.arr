use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
arctic-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1gg8qh72MrW-GZ5_vB8scCYlgDRGfGMAqv_9Sofsf9gs/")

#Column Title shorthand:
# gta = average global temperature anomaly
# asi = arctic sea ice extent

arctic-table = load-table: year,
  jan-gta,       # January annual temp anomaly (°C)
  feb-gta,       # February annual temp anomaly (°C)
  march-gta,     # March annual temp anomaly (°C)
  april-gta,     # April annual temp anomaly (°C)
  may-gta,       # May annual temp anomaly (°C)
  june-gta,      # June annual temp anomaly (°C)
  july-gta,      # July annual temp anomaly (°C)
  aug-gta,       # August annual temp anomaly (°C)
  sept-gta,      # September annual temp anomaly (°C)
  oct-gta,       # October annual temp anomaly (°C)
  nov-gta,       # November annual temp anomaly (°C)
  dec-gta,       # December annual temp anomaly (°C)
  annual-gta,    # Annual temp anomaly (°C)
  avg-asi,       # Average Arctic Sea Ice (precise km^2)
  relative-avg-asi, # Relatice Average Arctic Sea Ice
  min-asi,       # Minimum Arctic Sea Ice (precise km^2)
  max-asi,       # Maximum Arctic Sea Ice (precise km^2)
  month-ice-min, # Month with minimum sea ice
  month-ice-max, # Month with maximum sea ice
  global-sea-var, # Global mean Sea level Variation (precise mm)
  relative-global-sea-var, # Relative Global mean Sea level Variation
  global-co2     # Global CO2 level
  source: arctic-sheet.sheet-by-name("arctic sea level change over 40 years",
      true)
end

#########################################################
# Define some rows
year1979 = row-n(arctic-table, 0)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


