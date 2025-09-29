use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")

# Load your spreadsheet
shelter-sheet = load-spreadsheet("https://docs.google.com/spreadsheets/d/1VeR2_bhpLvnRUZslmCAcSRKfZWs_5RNVujtZgEl6umA/")

# load the 'animals' sheet as a table
animals-table = load-table: name, species, sex, age, fixed, legs, pounds, weeks
  source: shelter-sheet.sheet-by-name("pets", true)
end

####################################################
# Some dots to use
xxs-dot = circle(3, "solid", "black")
xs-dot  = circle(4, "solid", "red")
s-dot   = circle(5, "solid", "brown")
m-dot   = circle(6, "solid", "orange")
l-dot   = circle(7, "solid", "blue")
xl-dot  = circle(10, "solid", "green")

####################################################
# Some Helper Functions

# weight-dot :: (r :: Row) -> Image
fun weight-dot(r):
  if      (r["pounds"]  < 1)                           : xxs-dot
  else if ((r["pounds"] >= 1)  and (r["pounds"] < 5))  : xs-dot
  else if ((r["pounds"] >= 5)  and (r["pounds"] < 10)) : s-dot
  else if ((r["pounds"] >= 10) and (r["pounds"] < 50)) : m-dot
  else if ((r["pounds"] >= 50) and (r["pounds"] < 100)): l-dot
  else if (r["pounds"]  >= 100)                        : xl-dot
  end
end

####################################################
# Make the scatter plot!
# image-scatter-plot :: ( t :: Table, xs :: String, ys :: String, f :: (Row -> Image)) -> Image
image-scatter-plot(animals-table, "age", "weeks", weight-dot)


####################################################
# Can you write a piecewise function that makes different dots for animals that were adopted in under 2 weeks, 3 to 6 weeks, and over 6 weeks?