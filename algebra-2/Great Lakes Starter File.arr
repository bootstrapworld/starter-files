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
  level-m,  # water level in meters as compared to IGLD 1985 (see below for explanation)
  level-ft  #  water level in feet as compared to the International Great Lakes Datum of 1985 (IGLD 1985), a tide gauge located near the outlet of the Great Lakes-St. Lawrence River system in Rimouski, Quebec, the mean surface-water-level of which approximates mean sea level
  source: water-sheet.sheet-by-name("data", true)
end


######################################################### 
# Define some helper functions

# is-2016 :: Row -> Boolean
# is-2016 checks to see if a row in the dataset falls 
fun is-2016(r): (r["date"] > 2016) and (r["date"] < 2017) end

# filter our dataset to make a table of ONLY 2014 data
year-2016-table = filter(lakes-table, is-2016)


######################################################### 
# Define a PERIODIC model for the year-2016-table data
fun periodic-sin(x): (... * sin(... * (x - ...))) + ... end


######################################################### 
# EXAMPLE of how to write (and re-write!) the COSINE model from the CO2 dataset

# fun periodic-cos(x):  (4.13 * cos(6.28 * (x - 2023.35))) + 419.87 end
# fun wave-cos(x):      (4.13 * cos(6.28 * (x - 2023.35)))          end
# fun mid-line-cos(x):                                       419.87 end 
# fun periodic-cos2(x):         wave-cos(x)    +    mid-line-cos(x) end
######################################################### 

# Decompose (and re-compose) your periodic function using the EXAMPLE above.

fun wave(x):        ... end
fun mid-line(x):    ... end 
fun periodic(x):    ... end


######################################################### 
# Define a LINEAR MODEL for the lakes table - find it using lr-plot
fun trend-line(x):  ... end


######################################################### 
# Define a HYBRID MODEL using your wave and trend-line
fun hybrid(x):     ... end



# fit-model(year-2016-table, "month-name", "date", "level-ft", periodic)
# fit-model(lakes-table, "month-name", "date", "level-ft", hybrid)