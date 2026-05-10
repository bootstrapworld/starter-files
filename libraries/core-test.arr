use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/core", "../libraries/core.arr")
import csv as csv

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

_tri = triangle(20, "solid", "red")
_cir = circle(10, "solid", "yellow")
_sq = square(20, "solid", "blue")
_star = star(10, "solid", "pink")
_ellipse = ellipse(10, 20, "solid", "green")
_img-list = [list: _tri, _cir, _sq, _star, _ellipse]

examples "permute-wo-replace":
  permute-wo-replace([list: 1], 1) is [list: [list:1]]
  permute-wo-replace([list: 1, 2], 2) is [list: [list:1,2], [list:2,1]]
  permute-wo-replace([list: 1, 2, 3], 2) is [list:
    [list: 1, 2], [list: 1, 3],
    [list: 2, 1], [list: 2, 3],
    [list: 3, 1], [list: 3, 2]]
  permute-wo-replace([list: 1, 2, 3], 3) is [list:
    [list: 1, 2, 3], [list: 1, 3, 2],
    [list: 2, 1, 3], [list: 2, 3, 1],
    [list: 3, 1, 2], [list: 3, 2, 1]]
end

examples "permute-w-replace":
  permute-w-replace([list: 1], 1) is [list: [list:1]]
  permute-w-replace([list: 1, 2], 2) is [list: [list:1,1], [list:1,2], [list:2,1], [list:2,2]]
  permute-w-replace([list: 1, 2, 3], 2) is [list:
    [list: 1, 1], [list: 1, 2], [list: 1, 3],
    [list: 2, 1], [list: 2, 2], [list: 2, 3],
    [list: 3, 1], [list: 3, 2], [list: 3, 3]]
  permute-w-replace([list: 1, 2, 3], 3) is [list:
    [list: 1, 1, 1], [list: 1, 1, 2], [list: 1, 1, 3],
    [list: 1, 2, 1], [list: 1, 2, 2], [list: 1, 2, 3],
    [list: 1, 3, 1], [list: 1, 3, 2], [list: 1, 3, 3],
    [list: 2, 1, 1], [list: 2, 1, 2], [list: 2, 1, 3],
    [list: 2, 2, 1], [list: 2, 2, 2], [list: 2, 2, 3],
    [list: 2, 3, 1], [list: 2, 3, 2], [list: 2, 3, 3],
    [list: 3, 1, 1], [list: 3, 1, 2], [list: 3, 1, 3],
    [list: 3, 2, 1], [list: 3, 2, 2], [list: 3, 2, 3],
    [list: 3, 3, 1], [list: 3, 3, 2], [list: 3, 3, 3]]
end

examples "combine-wo-replace":
  combine-wo-replace([list:], 0) is [list: [list:]]
  combine-wo-replace([list:1], 1) is [list: [list: 1]]
  combine-wo-replace([list:1, 2], 1) is [list: [list:1], [list: 2]]
  combine-wo-replace([list:1, 2, 3], 2) is
  [list: [list:1,2], [list: 1,3], [list:2,3]]
end

examples "round-digits":
  round-digits(1.24, 1) is 1.2
  round-digits(num-sqrt(2), 3) is 1.414
end

examples "log functions":
  log-base(3, 9) is 2
  log-base(3, 1/9) is -2
  num-log(9) / num-log(3) satisfies num-is-roughnum
  log-base(4, 32) is 2.5
end


examples "easy-num-repr":
  easy-num-repr(0.0001234, 6) is "0.0001"
  easy-num-repr(2343.234, 6) is "2343.2"
  easy-num-repr(0.000000001234, 6) is "1.2e-9"
  easy-num-repr(2343243432.234, 6) is "2.34e9"
  easy-num-repr(~0.082805, 9) is "~0.082805"
  easy-num-repr(0.0999999, 5) is "0.100"
  easy-num-repr(0.9999999, 5) is "1"
  easy-num-repr(~-125137.47385839373, 8) is "~-125137"
  easy-num-repr(~-125137.67385839373, 8) is "~-125138"
  easy-num-repr(9999.99, 3) raises "Could not fit"
end


# Consts for testing print-imgs
img1 = rectangle(340,180,"outline","black")
img2 = rectangle(180, 50,"outline","black")
img3 = rectangle(50,340,"outline","black")
img4 = rectangle(270,75,"outline","black")
img5 = rectangle(510,75,"outline","black")
img6 = rectangle(270,510,"outline","black")
#img7 = circle(50,"outline","black")
#img8 = triangle(100,"outline","black")

test-lst = [list: img1, img2, img3, img4, img5, img6,]
print-imgs(test-lst)

# Consts for testing union and intersection
small-lst = [list: -4, -3, -2, -1, 1, 2, 3, 4]
big-lst = [list: -400, -300, -200, 100, 200, 300, 400, 1000]
fun is-positive(x): x > 0 end
fun gt5(x): x > 5 end
fun lt1(x): x < 1 end
fun lt15(x): x < 15 end


"A simple inequality, with feedback for num-passing"
inequality(is-positive, big-lst)
"A union with overlap"
or-union(gt5, lt15, range-by(3, 24 + 1, 3))
"A union with NO overlap"
or-union(lt1, gt5, range-by(-21, 24 + 1, 6))
"An intersection with overlap"
and-intersection(gt5, lt15, range-by(3, 24 + 1, 3))
"An intersection with NO overlap"
and-intersection(lt1, gt5, range-by(-21, 24 + 1, 6))



#####################################################################
## Image testing
examples:
  image-entropy(square(10, "solid", "black")) is 0
  image-entropy(square(10, "solid", "white")) is 0
  image-luminance(square(10, "solid", "black")) is 0
  image-luminance(square(10, "solid", "white")) is 255
  lighter(square(10, "solid", "black"), square(10, "solid", "white")) is square(10, "solid", "white")
  darker(square(10, "solid", "black"), square(10, "solid", "white")) is square(10, "solid", "black")
  image-symmetry-vertical(triangle(20, "solid", "red")) is 1
  image-symmetry-horizontal(triangle(20, "solid", "red")) is-not-roughly 1
  image-symmetry-vertical(circle(20, "solid", "red")) is 1
  image-symmetry-horizontal(circle(20, "solid", "red")) is 1
end


#####################################################################
## Chart testing

animals-url = "https://docs.google.com/spreadsheets/d/1VeR2_bhpLvnRUZslmCAcSRKfZWs_5RNVujtZgEl6umA/export?format=csv"


###################### Load the data ##########################
animals-table =
  load-table: name, species, sex, age, fixed, legs, pounds, weeks
  source: csv.csv-table-url(animals-url, {
    header-row: true,
    infer-content: true
  })
end

display-chart := lam(c) block: 
  when debugging: print(c.get-spec()) end
  c.get-image() 
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
   
   
examples "making regression functions":
  lr-fun(animals-table, "age", "name") raises "One or more of the columns (age or name) does not contain numeric data."
  mr-fun(animals-table, [list: "age","pounds"], "name") raises "One or more of the columns (age, pounds or name) does not contain numeric data."
  mr-fun(animals-table, [list: "age","species"], "weeks") raises "One or more of the columns (age, species or weeks) does not contain numeric data."
end


examples "S in Num->Num and Row->Num form":
  simple-S(animals-table, "age", "weeks", lam(x):  (0.78925 * x) + 2.309 end) is-roughly ~5.539741245494801
  S(animals-table, [list:"age"], "weeks", lam(r):  (0.78925 * r["age"]) + 2.309 end) is-roughly ~5.539741245494801
end

f = lr-fun(animals-table, "age", "weeks")
########################################################################
## Trig functions


examples:
  sin(PI) is-roughly 0
  sin(2 * PI) is-roughly 0
  sin(PI / 2) is-roughly 1
  sin((3 * PI) / 2) is-roughly -1
  cos(PI / 3) is-roughly 0.5
  sin(PI / 6) is-roughly 0.5
end