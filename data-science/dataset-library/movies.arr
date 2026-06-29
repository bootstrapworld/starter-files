use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
movies-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1xd1Egg6x3ZmqzsqQodNvxfSyhLgVnX2bJtQt8hzVjo0/")

movies-table = load-table:
  rank,            # movie Rank
  title,           # Title of movie
  studio,          # production Studio
  female-lead,     # does the movie have a Female Lead?
  passes-bechdel,  # does the movie Pass the Bechdel test?
  poc-lead,        # does the movie have a Person of Color as a lead?
  budget,          # what was the budget of the movie?
  total,           # Total revenue of the movie
  domestic,        # Domestic revenue
  overseas,        # International revenue
  year             # Year movie was released
  source: movies-sheet.sheet-by-name("2022", true)
end


# Note: A movie passes the Bechdel Test if it has at least 2 female characters, with names, who have a conversation about something other than men.

#########################################################
# Define some rows
avatar = row-n(movies-table, 0)




#########################################################
# Define some filter/builder functions




#########################################################
# Define random and logical subsets


