use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/algebra-2", "../libraries/core.arr")

#########################################################
# Load your spreadsheet and define your table
cabrera-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1Cw8D6Z5icjKM_MOra_0zQ1EBXCzPwpoYktGEw9AOTrA")

hit-table = load-table: 
  id,            # identifier column
  year,          # year of game (2020, 2021, 2022, or 2023)
  game-date,     # full date of game
  other-team,    # abbreviated name of other team (e.g. NYY, TOR, etc)
  pitch-type,    # type of pitch (e.g. - fastball, cutter, etc)
  pitch-speed,   # speed of the pitch
  hit-angle,     # angle of Miguel's bat
  hit-distance,  # how many feet the hit traveled
  hit-speed,     # speed of the ball, off the bat
  bb-type        # ball type (e.g. - line drive, ground ball, etc)
  source: cabrera-sheet.sheet-by-name("data", true)
end

######################################################### 
# Define a table of just the curve balls
fun is-curve(r) : r["pitch-type"] == "curveball" end
curve-table = filter(hit-table, is-curve)

# Define a table of just the 4 seam fast balls
fun is-four-seam(r) : r["pitch-type"] == "four-seam-fastball" end
fast4seam-table = filter(hit-table, is-four-seam)

# Define a table of just the sliders
fun is-slider(r) : r["pitch-type"] == "slider" end
sliders-table = filter(hit-table, is-slider)


######################################################### 
# DEFINE SOME MODELS by filling in "..."
# Predicting HIT-DISTANCE from BAT-ANGLE: 

# Best model you can fit visually for the curve ball data
fun curve(x):     (... * sqr(x - ...))  + ... end

# Best model you can fit visually for the sliders data
fun sliders(x):   (... * sqr(x - ...))  + ... end

# Best model you can fit visually for the four seam fastball data
fun fast4seam(x): (... * sqr(x - ...))  + ... end


# Model from Samples using standard form
fun f(x) : ((... * sqr(x)) + (... * x)) + ... end
######################################################### 