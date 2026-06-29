use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
income-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1rV7-XhGUbJCLPXcwZb1TNO9hEdDQ9bZq6lFByg_ORtQ")

income-table = load-table:
  year,              # Year data was gathered
  families,          # number of Families from which data was collected
  earned-under-15,   # % earning less than 15k
  earned-15-25,      # % earning between 15k-25k
  earned-25-35,      # % earning between 25k-35k
  earned-35-50,      # % earning between 35k-50k
  earned-50-75,      # % earning between 50k-75k
  earned-75-100,     # % earning between 75k-100k
  earned-100-150,    # % earning between 100k-150k
  earned-150-200,    # % earning between 150k-200k
  earned-over-200,   # % earning more than 200k
  median-income,     # median income across all families
  mean-income        # mean income across all families
  source: income-sheet.sheet-by-name("2020", true)
end


#########################################################
# Define some rows
income2018 = row-n(income-table, 0)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


