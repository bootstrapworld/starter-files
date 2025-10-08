use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr")
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

examples "num-to-sci":
  num-to-sci(0.00000343, 10) is "0.00000343" # max fixnum size (small)
  num-to-sci(0.000000343, 11) is "0.00000343"
  num-to-sci(0.00000343, 8) is "3.43e-6"
  num-to-sci(0.00000343, 9) is "3.43e-6"
  num-to-sci(4564634745675734, 16) is "4564634745675734" # max fixnum size (big)
  num-to-sci(45646347456757342, 17) is "45646347456757342"
  num-to-sci(45646347456757342, 16) is "4.56463474568e16"
  num-to-sci(4564634745675734, 15) is "4.5646347457e15"
  num-to-sci(-45646347456757342.000343, 16) is "-4.5646347457e16"
  num-to-sci(0.000001, 8) is "0.000001"
  num-to-sci(-0.000001, 8) is "-1.0e-6"
  num-to-sci(1/3, 18) is "0.3333333333333333"
  num-to-sci(1/3, 19) is "0.3333333333333333" # extra char is unused due to fixnum precision
  num-to-sci(1/3, 8) is "0.333333"
  num-to-sci(1 + 1/3, 8) is "1.333333"
  num-to-sci(2.712828, 7) is "2.71283" # rounding
  num-to-sci(3.1415962, 8) is "3.141596" # rounding
  num-to-sci(0.011238, 7) is "0.01124" # not 0.01123
  num-to-sci(12387691745124903567102, 7) is "1.24e22" # not 1.23876
  num-to-sci(0.0000000000456, 7) is "4.6e-11" # not 4.56e-1
  num-to-sci(203.680147, 9) is "203.68015" # not 2.0368e2
  num-to-sci(103.40123123,9) is "103.40123" # not 1.0340e2
  num-to-sci(20368014712358, 9) is "2.0368e13"

  num-to-sci(20368.0147, 9) is "20368.015"
  num-to-sci(203680.147, 9) is "203680.15"
  num-to-sci(2036801.47, 9) is "2036801.5"
  num-to-sci(20368014.7, 9) is "20368015" # "2.03680e7"
  num-to-sci(10939174.78308761, 8) is "10939175"

  num-to-sci(0.00001284567, 8) is "1.285e-5" # "0.00001"
  num-to-sci(0.00001284567, 9) is "1.2846e-5" # "0.000013"
  num-to-sci(0.00001234567, 7) is "1.23e-5" # "1.2e-5"
  num-to-sci(0.000001239567, 8) is "1.240e-6"

  num-to-sci(0.0999999, 5) is "0.100"
  num-to-sci(0.9999999, 5) is "1"

  num-to-sci(9999.99, 3) raises "Could not fit"
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

examples "rough-round-digits":
  rough-round-digits(1.24, 1) is-roughly ~1.2
  rough-round-digits(num-sqrt(2), 3) is-roughly ~1.414
end


# fun t():
#   # easy-num-repr(0.0001234, 6)
#   # [list: easy-num-repr(2343.234, 6), "2343.2"]
#   # [list: easy-num-repr(0.000000001234, 6) , 0.000000001234, 6, "1.2e-9"]
#   # [list: easy-num-repr(0.0001234, 6) , "0.0001"]
#   num-to-sci(20368014.7, 9) # "20368015"
#   # num-to-sci(100000, 2)
#   # easy-num-repr(~0.082805, 9)
#   # [list: shrink-dec("0.9999999", 5), shrink-dec-part("99999999", 3)]
#   # num-to-sci(0.099999, 5)
#   # easy-num-repr(0.099999,5)
#   # [list: easy-num-repr(0.0001234, 6), "0.0001"]
#   # [list: num-to-sci(20368014.7, 9), "20368014"]
#   # [list: num-to-sci(0.00001234567, 7), "1.2e-5"]
# easy-num-repr(~-125137.67385839373,8)
# end

# num-to-sci(203.680147,9) should evaluate to ~203.6801 instead of ~2.0368e2


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
## Chart testing

csv-url = "https://raw.githubusercontent.com/bootstrapworld/curriculum/refs/heads/master/lib/pyret-support/Animals-Dataset-1.5.1.csv"

animals-table =
  load-table: name, species, sex, age, fixed, legs, pounds, weeks
    source: csv.csv-table-url(csv-url, {
    header-row: true,
    infer-content: true
  })
end

pie-chart(animals-table, "species")
bar-chart(animals-table, "species")
# we no longer support image-pie-chart
#image-pie-chart(animals-table, "species", lam(x): circle(10,"solid","red") end)
image-bar-chart(animals-table, "species", lam(x): circle(10,"solid","red") end)
dot-plot(animals-table, "name", "pounds")
scatter-plot(animals-table, "name", "weeks", "pounds")
histogram(animals-table, "name", "pounds", 7)
box-plot(animals-table, "weeks")

split-and-reduce(animals-table, "species", "pounds", sum)
group-and-subgroup(animals-table, "species", "sex")
group(animals-table, "sex")


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
