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


## Staggered x-axis label demonstration ##############################
# These region names are long enough that n × max_label_chars > 85
# (7 regions × 26 chars = 182 > 85), so all charts below should
# auto-stagger their x-axis labels via crowded-x-labels().

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

# dot-chart-window charts — use .x-axis-stagger-labels()
simple-dot-plot(region-data, "region")
dot-plot(region-data, "region", "pop")
color-dot-plot(region-data, "pop", lam(r): if r["income-level"] == "high": "steelblue" else: "tomato" end end)

# bar-chart-window charts — use .x-axis-stagger()
bar-chart(region-data, "region")
image-bar-chart(region-data, "region", lam(r): circle(10, "solid", "steelblue") end)
stacked-bar-chart(region-data, "region", "income-level")
multi-bar-chart(region-data, "region", "income-level")

# Quarterly decimal-year data triggers crowded-numeric-x-axis on plot charts.
# 16 distinct values, max label length 7 ("2018.25") → min(16,20) × 7 = 112 > 85.
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

# plot-chart-window charts — use .x-axis-stagger()
scatter-plot(lake-level, "name", "date", "level-ft")
simple-scatter-plot(lake-level, "date", "level-ft")
lr-plot(lake-level, "name", "date", "level-ft")
simple-lr-plot(lake-level, "date", "level-ft")
fit-model(lake-level, "name", "date", "level-ft", lam(x): (0.1 * x) + 400 end)
line-graph(lake-level, "name", "date", "level-ft")

examples "crowded-x-labels — categorical":
  # 7 long region names: 7 × 26 = 182 > 85 → crowded
  crowded-x-labels([L.list:
    "Latin America & Caribbean",
    "Sub-Saharan Africa",
    "East Asia & Pacific",
    "Europe & Central Asia",
    "Middle East & North Africa",
    "North America",
    "South Asia"]) is true
  # 6 short animal species names: 6 × 9 = 54 ≤ 85 → not crowded
  crowded-x-labels([L.list: "cat", "dog", "rabbit", "tarantula", "lizard", "snail"]) is false
end

examples "crowded-numeric-x-axis":
  # 16 quarterly decimal years, capped at min(16,10) = 10, max label 7 chars: 10 × 7 = 70 ≤ 85
  # Vega only generates ~8 ticks for this range, so stagger is not needed.
  crowded-numeric-x-axis([L.list:
    2018.00, 2018.25, 2018.50, 2018.75,
    2019.00, 2019.25, 2019.50, 2019.75,
    2020.00, 2020.25, 2020.50, 2020.75,
    2021.00, 2021.25, 2021.50, 2021.75]) is false
  # 10 small integers (max label "10" = 2 chars): 10 × 2 = 20 ≤ 85 → not crowded
  crowded-numeric-x-axis([L.list: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) is false
  # 101 distinct years, capped at min(101,10) = 10, label "1920" = 4 chars: 10 × 4 = 40 ≤ 85
  crowded-numeric-x-axis(L.range(1920, 2021)) is false
  # 10 large integers with 10-char labels: 10 × 10 = 100 > 85 → crowded
  crowded-numeric-x-axis([L.list:
    1000000001, 2000000002, 3000000003, 4000000004, 5000000005,
    6000000006, 7000000007, 8000000008, 9000000009, 1000000010]) is true
end