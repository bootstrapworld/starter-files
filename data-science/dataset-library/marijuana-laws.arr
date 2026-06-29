use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
marijuana-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1TB0Lj88IH1bdAAKAxwsFMW-x-B-JtnLate4ArmSWDzk")

# short-hand for column titles:
# a stands for arrests
# m stands for marijuana
# p stands for possession
marijuana-table = load-table:
  state,      # name of State
  drug-a,     # number of Drug-related Arrests
  tot-ma,     # Total Marijuana-related Arrests
  mpa,        # Arrests for Marijuana Possession
  black-mpa,  # Arrests for Marijuana Possession (black suspect)
  white-mpa,  # Arrests for Marijuana Possession (white suspect)
  black-pop,  # number of Black citizens in the state
  white-pop,  # number of White citizens in the state
  tot-pop,    # Total Population in the state
  m-legal,    # "Is Marijuana Legal?" (if yes, the year it was legalized)
  m-decriminalized, # "Is Marijuana Decriminalized?" (if yes, the year it was decriminalized)
  medical-m   # "Is Marijuana Legal for medical uses?" (if yes, the year it was legalized for medical use)
  source: marijuana-sheet.sheet-by-name("Marijuana Laws & Arrests by State", true)
end


#########################################################
# Define some rows
oklahoma = row-n(marijuana-table, 34)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets