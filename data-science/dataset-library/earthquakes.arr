use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")


# Load your spreadsheet and define your table
eq-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1ffJpn6BlAzN51XFd9nZ_CcTUmNqkp1DoNMOcn3ebcIk")

eq-table = load-table:
  time,     # timestamp when earthquake occurred
  where,    # location
  gdp,      # Gross Domestic Product (in millions of US$)
  gdp-pc,   # Per-Capita Gross Domestic Product (in millions of US$)
  yr,       # Year
  mo,       # Month (1-12)
  day,      # Name of Day
  lat, long,# Coordinates of epicenter
  depth-km, # Depth of epicenter in (km)
  mag,      # Magnitude
  land,     # Did the earthquake happen on land?
  eq-type,  # Type of Earthquake
  plate-1,  # First Plate involved in quake
  plate-2,  # Second Plate involved in quake
  tsunami,  # Did the quake trigger a tsunami?
  deaths,   # Number of deaths attributed to quake
  injuries  # Number of injuries attributed to quake
  source: eq-sheet.sheet-by-name("Sheet1",
  true) end

# gpd & gdp-pc (per capita) are given in millions of US$
# lat, long, mag = latitude, longitude & magnitude

#########################################################
# Define some rows
peru-nov-2021 = row-n(eq-table, 2)

ca-jul-2019 = row-n(eq-table, 25)





#########################################################
# Define some helper functions
fun is-high-mag(r):
  r["mag"] >= 8
end

fun high-casualty(r):
  (r["deaths"] + r["injuries"]) > 1000
end


#########################################################
# Define random and logical subsets
