use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
nypd-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1XrJPOeIJCavRjP1nHbWYKcGo79dO-x_XidLplJabGko/")

nypd-table = load-table:
  id,            # identifier column (unique to each row)
  suspected-of,  # crime the NYPD Suspected a person of commiting
  min-observed,  # Minutes Observed before stop
  searched,      # was a Search performed at the stop?
  frisked,       # was a Frisk performed at the stop?
  asked-consent, # was Consent requested?
  given-consent, # was Consent Given?
  weapon-found,  # was a Weapon Found?
  arrested,      # did the stop result in an Arrest?
  time,          # time of day (note: many of these are blank!)
  month,         # month when stop was performend
  day,           # day of the week when stop was performed
  officer-rank,  # Rank of Officer
  in-uniform,    # was the officer In Uniform?
  age,           # Age of person stopped
  sex,           # Sex of person stopped
  race,          # Race of person stopped
  eye,           # Eye color of person stopped
  hair,          # Hair color of person stopped
  demeanor,      # Demeanor of person stopped
  boro           # Boro where person was stopped
  source: nypd-sheet.sheet-by-name("stop-question-frisk-2019", true)
end


#########################################################
# Define some rows
first-row = row-n(nypd-table, 0)




#########################################################
# Define some helper functions




#########################################################
# Define random and logical subsets


