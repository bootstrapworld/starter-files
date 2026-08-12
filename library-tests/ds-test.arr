use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/refactor/", "libraries/ds-tools.arr")
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