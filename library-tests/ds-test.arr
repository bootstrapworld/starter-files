use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ds-tools.arr")
import lists as L
import csv as csv
include image

animals-url = "https://docs.google.com/spreadsheets/d/1VeR2_bhpLvnRUZslmCAcSRKfZWs_5RNVujtZgEl6umA/export?format=csv"


###################### Load the data ##########################
animals-table =
  load-table: name, species, sex, age, fixed, legs, pounds, weeks
  source: csv.csv-table-url(animals-url, {
    header-row: true,
    infer-content: true
  })
end

# animal-img :: (r :: Row) -> Image
fun animal-color(r):
  if      (r["species"] == "dog"):       "red"
  else if (r["species"] == "cat"):       "blue"
  else if (r["species"] == "rabbit"):    "green"
  else if (r["species"] == "tarantula"): "yellow"
  else if (r["species"] == "lizard"):    "pink"
  else if (r["species"] == "snail"):     "black"
  end
end

pie-chart(animals-table, "species")
bar-chart(animals-table, "species")
# we no longer support image-pie-chart
color-pie-chart(animals-table, "species", animal-color)
color-bar-chart(animals-table, "species", animal-color)
image-bar-chart(animals-table, "species", lam(x): circle(10,"solid","red") end)
color-dot-plot(animals-table, "pounds", animal-color)
dot-plot(animals-table, "name", "pounds")
scatter-plot(animals-table, "name", "weeks", "pounds")
simple-scatter-plot(animals-table, "weeks", "pounds")
color-scatter-plot(animals-table, "weeks", "pounds", animal-color)
lr-plot(animals-table, "name", "weeks", "pounds")
histogram(animals-table, "name", "pounds", 7)
color-histogram(animals-table, "pounds", 7, animal-color)
box-plot(animals-table, "weeks")
image-scatter-plot(animals-table, "pounds", "weeks", lam(r): circle(r["age"],"solid","red") end)

split-and-reduce(animals-table, "species", "pounds", sum)
group-and-subgroup(animals-table, "species", "sex")
group(animals-table, "sex")
fit-model(animals-table, "name", "pounds", "weeks", lam(x): x + 1 end)
stacked-bar-chart(animals-table, "species", "fixed")

   
   
examples "making regression functions":
  lr-fun(animals-table, "age", "name") raises "One or more of the columns (age or name) does not contain numeric data."
  regression-model-fun(animals-table, [L.list: "age","pounds"], "name") raises "One or more of the columns (age, pounds or name) does not contain numeric data."
  regression-model-fun(animals-table, [L.list: "age","species"], "weeks") raises "One or more of the columns (age, species or weeks) does not contain numeric data."
end


examples "S in Num->Num and Row->Num form":
  S(animals-table, "age", "weeks", lam(x):  (0.78925 * x) + 2.309 end) is-roughly ~5.539741245494801
  regression-model-S(animals-table, [L.list:"age"], "weeks", lam(r):  (0.78925 * r["age"]) + 2.309 end) is-roughly ~5.539741245494801
end

f = lr-fun(animals-table, "age", "weeks")


height = table: player, inches
  row: "RJ Barrett", 78
  row: "Jusuf Nurkic", 84
  row: "James Harden", 77
  row: "Rodney Hood", 80
  row: "Jae'Sean Tate", 76
  row: "Nikola Jokic", 83
  row: "E'Twaun Moore", 76
  row: "Dario Saric", 82
  row: "Tim Frazier", 73
  row: "Brad Wanamaker", 75
end


examples "variance":
  pop-variance(height, "inches") is 12.24
  sample-variance(height, "inches") is 13.6
end


small = table: x :: Number
  row: 2
  row: 4
  row: 4
  row: 4
  row: 5
  row: 5
  row: 7
  row: 9
end

xy = table: x :: Number, y :: Number
  row: 1, 2
  row: 2, 4
  row: 3, 6
end

examples "stats basics":
  mean(small, "x") is 5
  median(small, "x") is-roughly 4.5
  modes(small, "x") is [L.list: 4]
  sum(small, "x") is 40
  stdev(small, "x") is-roughly 2.13809
  r-value(xy, "x", "y") is-roughly 1
end

skewed = table: x :: Number
  row: 1
  row: 2
  row: 3
  row: 4
  row: 100
end

examples "quartiles and outliers":
  q1(skewed, "x") is-roughly 1.5
  q3(skewed, "x") is-roughly 52
  compute-outliers(skewed, "x").get-column("is-outlier") is [L.list: "no", "no", "no", "no", "no"]
  outliers(skewed, "x").get-column("x") is [L.list: ]
  remove-outliers(skewed, "x").get-column("x") is [L.list: 1, 2, 3, 4, 100]
end

examples "count":
  count(small, "x").get-column("frequency") is [L.list: 1, 3, 2, 1, 1]
end

wide = table: label, a, b
  row: "row1", 1, 2
end
transposed = transpose(wide)
examples "transpose":
  transposed.column-names() is [L.list: "label", "row1"]
  transposed.get-column("label") is [L.list: "a", "b"]
  transposed.get-column("row1") is [L.list: 1, 2]
end

examples "word-frequency":
  word-frequency("the cat sat on the mat").get-column("count") is [L.list: 2, 1, 1, 1, 1]
end

check "word-cloud-font-size":
  word-cloud-font-size(1, 1, 9) is WORD-CLOUD-MIN-FONT
  word-cloud-font-size(9, 1, 9) is WORD-CLOUD-MAX-FONT
  # sizes grow with the square root of the count: a quarter of the way up the counts is half way up the sizes
  word-cloud-font-size(3, 1, 9) is ((WORD-CLOUD-MIN-FONT + WORD-CLOUD-MAX-FONT) / 2)
  # when every word is equally frequent, they are all the same size, half way between
  word-cloud-font-size(4, 4, 4) is ((WORD-CLOUD-MIN-FONT + WORD-CLOUD-MAX-FONT) / 2)
end

fun overlap-free(a, b):
  ((num-abs(a.{1} - b.{1}) * 2) >= (a.{3} + b.{3} + WORD-CLOUD-PADDING))
    or ((num-abs(a.{2} - b.{2}) * 2) >= (a.{4} + b.{4} + WORD-CLOUD-PADDING))
end
fun no-overlaps(placed):
  placed.all(lam(a): placed.all(lam(b): (a.{0} == b.{0}) or overlap-free(a, b) end) end)
end
fun on-canvas(placed):
  placed.all(lam(p):
    ((p.{1} - (p.{3} / 2)) >= 0) and ((p.{1} + (p.{3} / 2)) <= WORD-CLOUD-WIDTH)
      and ((p.{2} - (p.{4} / 2)) >= 0) and ((p.{2} + (p.{4} / 2)) <= WORD-CLOUD-HEIGHT)
  end)
end
fun sample-items(n):
  L.range(0, n).map(lam(i): {"w" + to-string(i); 40 + num-modulo(i * 37, 90); 14 + num-modulo(i * 11, 40)} end)
end

check "word-cloud-layout":
  placed = word-cloud-layout([L.list: {"big"; 200; 80}, {"mid"; 120; 40}, {"small"; 60; 20}])
  # every word is placed, in order, and the first goes in the middle of the canvas
  placed.map(lam(p): p.{0} end) is [L.list: "big", "mid", "small"]
  placed.get(0).{1} is (WORD-CLOUD-WIDTH / 2)
  placed.get(0).{2} is (WORD-CLOUD-HEIGHT / 2)
  # each keeps the size it was given
  placed.map(lam(p): p.{3} end) is [L.list: 200, 120, 60]
  placed.map(lam(p): p.{4} end) is [L.list: 80, 40, 20]
  no-overlaps(placed) is true
  on-canvas(placed) is true
  # the same words always land in the same places
  word-cloud-layout(sample-items(20)) is word-cloud-layout(sample-items(20))
  # nothing to place
  word-cloud-layout([L.list:]) is [L.list:]
end

check "word-cloud-layout with many words":
  placed = word-cloud-layout(sample-items(30))
  placed.length() is 30
  no-overlaps(placed) is true
  on-canvas(placed) is true
end

check "word-cloud-layout when words do not fit":
  # a word wider than the canvas is left out, and the rest are still placed
  word-cloud-layout([L.list: {"wide"; 900; 20}, {"ok"; 50; 20}]).map(lam(p): p.{0} end) is [L.list: "ok"]
  # too many big words: only some fit, but those never overlap or leave the canvas
  crowded = word-cloud-layout(L.range(0, 40).map(lam(i): {"c" + to-string(i); 300; 120} end))
  (crowded.length() < 40) is true
  (crowded.length() > 0) is true
  no-overlaps(crowded) is true
  on-canvas(crowded) is true
end

check "word-cloud":
  c = word-cloud("the cat sat on the mat the cat ran")
  image-width(c) is WORD-CLOUD-WIDTH
  image-height(c) is WORD-CLOUD-HEIGHT
  # one word, and one repeated word
  image-width(word-cloud("hello")) is WORD-CLOUD-WIDTH
  image-height(word-cloud("hello hello hello")) is WORD-CLOUD-HEIGHT
  # punctuation and capitals are handled the way word-frequency handles them
  image-width(word-cloud("Hello, hello! HELLO? hello...")) is WORD-CLOUD-WIDTH
  # text with no words in it says so
  word-cloud("") raises "needs some words"
  word-cloud("123 !!! ???") raises "needs some words"
end

check "word-cloud with more words than it draws":
  letters = string-explode("abcdefgh")
  pairs = L.foldr(lam(row, acc): row + acc end, [L.list:], letters.map(lam(a): letters.map(lam(b): a + b end) end))
  (pairs.length() > WORD-CLOUD-MAX-WORDS) is true
  big = word-cloud(pairs.join-str(" "))
  image-width(big) is WORD-CLOUD-WIDTH
  image-height(big) is WORD-CLOUD-HEIGHT
end

examples "pivot-row":
  pivot-row(row-n(xy, 0)).get-column("labels") is [L.list: "x", "y"]
end

t1 = table: id :: String, x :: Number
  row: "a", 3
  row: "b", 1
  row: "c", 2
end

examples "sort/filter shadows":
  sort(t1, "x", true).get-column("id") is [L.list: "b", "c", "a"]
  filter(t1, lam(r): r["x"] > 1 end).get-column("id") is [L.list: "a", "c"]
end

examples "find-by-id / row-id":
  find-by-id(t1, "b")["x"] is 1
  row-id(t1, "b")["x"] is 1
end

t2 = table: id :: String, x :: Number
  row: "d", 4
end
examples "stack-table / stack-tables":
  stack-table(t1, t2).get-column("id") is [L.list: "a", "b", "c", "d"]
  stack-tables([L.list: t1, t2]).get-column("id") is [L.list: "a", "b", "c", "d"]
end

examples "first-n-rows / last-n-rows":
  first-n-rows(t1, 2).get-column("id") is [L.list: "a", "b"]
  last-n-rows(t1, 2).get-column("id") is [L.list: "b", "c"]
end

lin = table: x :: Number, y :: Number
  row: 1, 3
  row: 2, 5
  row: 3, 7
  row: 4, 9
end
fun predictor(r): (2 * r["x"]) + 1 end

examples "predict-col":
  predict-col(lin, "y", predictor).get-column("Error") is [L.list: 0, 0, 0, 0]
end

examples "residuals / mr-residuals":
  residuals(lin, "x", "y", lam(x): (2 * x) + 1 end) is [L.list: 0, 0, 0, 0]
  mr-residuals(lin, [L.list: "x"], "y", predictor) is [L.list: 0, 0, 0, 0]
end

lin-coeffs = regression-model-coeffs(lin, [L.list: "x"], "y").get-column("coefficient-value")
examples "regression-model-coeffs / lr-coeffs":
  lin-coeffs.get(0) is-roughly 1
  lin-coeffs.get(1) is-roughly 2
  lr-coeffs(lin, "x", "y").get-column("coefficient-value").get(1) is-roughly 2
end

pt = table: before :: Number, after :: Number
  row: 10, 11
  row: 20, 23
  row: 30, 33
  row: 40, 46
end
examples "t-tests":
  # diffs = [1, 3, 3, 6]; paired-t = mean-diff / (stdev(diffs) / sqrt(n))
  paired-t(pt, "before", "after") is-roughly ~-3.1529631254723287
  eq-variance-t(pt, "before", "after") satisfies num-is-roughnum
  uneq-variance-t(pt, "before", "after") satisfies num-is-roughnum
end


## Long-label chart demonstration ##############################
# These region names are long enough to trigger Pyret's built-in
# auto-stagger for x-axis labels.

region-data = table: region :: String, income-level :: String, pop :: Number
  row: "Latin America & Caribbean",  "middle", 656
  row: "Latin America & Caribbean",  "middle", 742
  row: "Sub-Saharan Africa",          "low",    125
  row: "Sub-Saharan Africa",          "low",    209
  row: "East Asia & Pacific",         "middle", 1387
  row: "East Asia & Pacific",         "high",   512
  row: "Europe & Central Asia",       "high",   318
  row: "Europe & Central Asia",       "high",   286
  row: "Middle East & North Africa",  "middle", 443
  row: "Middle East & North Africa",  "middle", 398
  row: "North America",               "high",   369
  row: "South Asia",                  "low",    1780
  row: "South Asia",                  "low",    214
end

simple-dot-plot(region-data, "region")
dot-plot(region-data, "region", "pop")
color-dot-plot(region-data, "pop", lam(r): if r["income-level"] == "high": "steelblue" else: "tomato" end end)

bar-chart(region-data, "region")
image-bar-chart(region-data, "region", lam(r): circle(10, "solid", "steelblue") end)
stacked-bar-chart(region-data, "region", "income-level")
multi-bar-chart(region-data, "region", "income-level")

lake-level = table: date :: Number, level-ft :: Number, name :: String
  row: 2018.00, 580.5, "Jan 2018"
  row: 2018.25, 580.2, "Apr 2018"
  row: 2018.50, 581.1, "Jul 2018"
  row: 2018.75, 579.7, "Oct 2018"
  row: 2019.00, 581.2, "Jan 2019"
  row: 2019.25, 580.8, "Apr 2019"
  row: 2019.50, 581.6, "Jul 2019"
  row: 2019.75, 580.4, "Oct 2019"
  row: 2020.00, 581.9, "Jan 2020"
  row: 2020.25, 580.1, "Apr 2020"
  row: 2020.50, 582.3, "Jul 2020"
  row: 2020.75, 579.8, "Oct 2020"
  row: 2021.00, 581.5, "Jan 2021"
  row: 2021.25, 580.6, "Apr 2021"
  row: 2021.50, 582.0, "Jul 2021"
  row: 2021.75, 579.3, "Oct 2021"
end

scatter-plot(lake-level, "name", "date", "level-ft")
simple-scatter-plot(lake-level, "date", "level-ft")
lr-plot(lake-level, "name", "date", "level-ft")
simple-lr-plot(lake-level, "date", "level-ft")
fit-model(lake-level, "name", "date", "level-ft", lam(x): (0.1 * x) + 400 end)
line-graph(lake-level, "name", "date", "level-ft")

