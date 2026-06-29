use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")


# Load your spreadsheet and define your table
global-waste-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1TOzs9GqIJIF9P6LVsGnt3Q6rueG43CYKQMoJrigJy-c")

waste-table = load-table: 
  country,    # Country name
  region,     # Region of the world
  economy,    # Economic Development (developed, in transition, etc)
  GDP,        # Gross Domestic Product
  msw,        # total Municipal Solid Waste per year (tons)
  pop,        # total Population
  haz,        # total Hazardous Solid Waste per year (tons)
  agency,     # does the country have an agency that enforces waste laws?
  laws,       # are there laws regarding solid waste?
  msw-pc,     # Per-Capita Municipal Solid Waste per year (tons)
  haz-pc,     # Per-Capita Hazardous Solid Waste per year (tons)
  urban-pct,  # Percent of population living in urban settings
  urban-growth, # rate of urbanization
  hdi,        # Human Development Index (0-1)
  obesity     # Percent of Adults whose BMI labels them as obese
  source: global-waste-sheet.sheet-by-name("Global Waste", 
      true)
end

######################################################### 
# Define some rows
albania = row-n(waste-table, 2)
united-states = row-n(waste-table, 163)



######################################################### 
# Define some helper functions





######################################################### 
# Define random and logical subsets