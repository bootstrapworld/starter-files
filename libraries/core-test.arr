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
