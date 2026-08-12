use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/refactor/", "libraries/foundations.arr")

import lists as L
import constants as Consts
import image as I
include option

examples "string-trim":
  string-trim("  hello  ")   is "hello"
  string-trim("\t hi \n")    is "hi"
  string-trim("no-spaces")   is "no-spaces"
  string-trim("   ")         is ""
  string-trim("")            is ""
end

examples "sort-strings-ci":
  sort-strings-ci([L.list: "Banana", "apple", "Cherry"]) is [L.list: "apple", "Banana", "Cherry"]
  sort-strings-ci([L.list: "Z", "a", "M"])               is [L.list: "a", "M", "Z"]
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
  log(100) is 2
  ln(num-exp(1)) is-roughly 1
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

examples "Posn":
  posn(3, 4).x is 3
  posn(3, 4).y is 4
end

examples "make-color":
  make-color(255, 0, 0, 1).red is 255
  make-color(10, 20, 30, 0.5).alpha is 0.5
end

range-table = table: x :: Number
  row: 1
  row: 5
  row: 3
end
examples "range (table stat shadow)":
  range(range-table, "x") is "4.00"
end

examples "nth-root":
  nth-root(8, 3) is-roughly 2
  nth-root(16, 4) is-roughly 2
end

examples "num-round-to":
  num-round-to(3.14159, 2) satisfies num-is-roughnum
  num-round-to(3.14159, 2) is-roughly 3.14
end

examples "degree-based trig":
  sin-deg(90) is-roughly 1
  cos-deg(60) is-roughly 0.5
  tan-deg(45) is-roughly 1
end

examples "maybe-get-value":
  maybe-get-value(lam(): 1 + 1 end) is some(2)
  maybe-get-value(lam(): raise("boom") end) is none
end

arity-f1 = lam(x): x end
arity-f2 = lam(x, y): x + y end
arity-f3 = lam(x, y, z): x + y + z end
examples "guess-arity":
  guess-arity(arity-f1) satisfies is-one
  guess-arity(arity-f2) satisfies is-two
  guess-arity(arity-f3) satisfies is-three
end

red-sq = I.square(10, "solid", "red")
black-sq = I.square(10, "solid", "black")
white-sq = I.square(10, "solid", "white")
examples "image tools":
  dominant-rgb-colors(red-sq) satisfies
    lam(s): string-contains(s, "red") and not(string-contains(s, "blue")) and not(string-contains(s, "green")) end
  invert(black-sq) is white-sq
  invert(white-sq) is black-sq
  grayscale(red-sq) is greyscale(red-sq)
  combine-images(black-sq, white-sq, lam(c1, c2): c2 end) is white-sq
  blend-images(black-sq, black-sq) is black-sq
  count-dominant-pixels(red-sq, "red") is 100
  image-red-pixels(red-sq) is 100
  image-green-pixels(red-sq) is 0
  image-blue-pixels(I.square(10, "solid", "blue")) is 100
end

examples "translate/dilate shadows":
  translate(I.circle(5, "solid", "red"), 0, 0, I.rectangle(20, 20, "solid", "transparent"))
    is I.put-image(I.circle(5, "solid", "red"), 0, 0, I.rectangle(20, 20, "solid", "transparent"))
  dilate(2, red-sq) is I.scale(2, red-sq)
end

examples "text tools":
  num-words("the quick brown fox") is 4
  num-words("  extra   spaces  ") is 2
  num-sentences("One. Two. Three.") is 3
  num-syllables("cat") is 1
  num-syllables("banana") is 3
end

examples "image analysis":
  image-entropy(I.square(10, "solid", "black")) is 0
  image-entropy(I.square(10, "solid", "white")) is 0
  image-luminance(I.square(10, "solid", "black")) is 0
  image-luminance(I.square(10, "solid", "white")) is 255
  lighter(I.square(10, "solid", "black"), I.square(10, "solid", "white")) is I.square(10, "solid", "white")
  darker(I.square(10, "solid", "black"), I.square(10, "solid", "white")) is I.square(10, "solid", "black")
  image-symmetry-vertical(I.triangle(20, "solid", "red")) is 1
  image-symmetry-horizontal(I.triangle(20, "solid", "red")) is-not-roughly 1
  image-symmetry-vertical(I.circle(20, "solid", "red")) is 1
  image-symmetry-horizontal(I.circle(20, "solid", "red")) is 1
end

examples "trig functions":
  sin(Consts.PI) is-roughly 0
  sin(2 * Consts.PI) is-roughly 0
  sin(Consts.PI / 2) is-roughly 1
  sin((3 * Consts.PI) / 2) is-roughly -1
  cos(Consts.PI / 3) is-roughly 0.5
  sin(Consts.PI / 6) is-roughly 0.5
end
