use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/main/algebra-2", "../libraries/core.arr")

#########################################################
# The dataset used in this file focuses on mean monthly water levels in the Great Lakes as compared to the International Great Lakes Datum of 1985 (IGLD 1985), a tide gauge located near the outlet of the Great Lakes - St. Lawrence River system in Rimouski, Québec, the mean surface-water-level of which approximates mean sea level

# Load your spreadsheet 
water-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1Cz68Sx4JqP1bMKKYYlRvG3SG6F8Kl44YywA5nvndc4s/")

# Define your table
lakes-table = load-table: # List all of the columns in the table
  date,     # July 2nd, 1990 would be represented as "1990.5"
  year,     # e.g. 1981, 1994, etc. 
  month,    # e.g. 1=January, 2=February, etc.
  month-name, 
  level-m,  # water level in meters
  level-ft  # water level in feet 
  source: water-sheet.sheet-by-name("data", true)
end

# This 
######################################################### 
# Define some helper functions

# is-2016 :: Row -> Boolean
# is-2016 checks to see if a row in the dataset falls 
fun is-2016(r): (r["date"] > 2016) and (r["date"] < 2017) end

# filter our dataset to make a table of ONLY 2014 data
year-2016-table = filter(lakes-table, is-2016)


######################################################### 
# Define some models

# a periodic model using sine (instead of cosine)
# fun periodic-sin(x): (... * sin(... * (x - ...))) + ... end