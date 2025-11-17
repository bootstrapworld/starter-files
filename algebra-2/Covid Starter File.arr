use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/algebra-2", "../libraries/core.arr")

#########################################################
# Load your spreadsheet
covid-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1GFWesAyYshYXDDSTxoHYmFrPVDTQd12rEVR-ZGn11hg/")

# Define your table
covid-table = load-table: # NOTES ON COLUMNS:
  state,             # the state reporting the data
  days-since-jan1,   # number of days since 1/1/2020
  positive,          # TOTAL number of positive covid cases
  deaths             # TOTAL number of deaths due to covid
  source: covid-sheet.sheet-by-name("CA, MN, MI, WI, IL, and OH in 2020", true) 
end


######################################################### 
# Define some rows

CA15 = row-n(covid-table, 0)
CA22 = row-n(covid-table, 1)
MI15 = row-n(covid-table, 102)


######################################################### 
# Define some helper functions

# is-MI :: Row -> Boolean
# consumes a Row, and checks if state == "MI"
fun is-MI(r): r["state"] == "MI" end

######################################################### 
# Filter the covid-table by is-MI, and 
# save the result as MI-table

MI-table = filter(covid-table, is-MI)

######################################################### 
# Define some models

# linear : Number -> Number
# after completing the 'Linear Models' workbook page,
# change the function below to match the function from your lr-plot
fun linear(x):  (... * x) + ... end

# quadratic1 : Number -> Number
# after completing the 'Quadratic Models' workbook page,
# change the function below to be your first model
fun quadratic1(x):  (... * sqr(x - ...)) + ... end
	

# quadratic2 : Number -> Number
# after completing the 'Quadratic Models' workbook page,
# change the function below to be your second model
fun quadratic2(x):  (... * sqr(x - ...)) + ... end

# quadratic3 : Number -> Number
# after completing the 'Quadratic Models' workbook page,
# change the function below to be your third model
fun quadratic3(x):  (... * sqr(x - ...)) + ... end

# exponential : Number -> Number
# after completing the 'Exponential Models' workbook page,
# change the function below to be your first model
fun exponential(x):  (... * expt(..., (~1 * x))) + ... end

