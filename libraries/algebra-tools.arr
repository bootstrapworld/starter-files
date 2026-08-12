use context starter2024

provide *

import error as Err
import lists as L
import math as Math
import sets as Sets

# brings in foundations.arr's unqualified names (make-color, etc.)
include url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "foundations.arr")

####################################################################
# algebra-tools.arr
#
# The inequality-simulator drawing functions, plus permutations and
# combinations helpers.
#
# Split out of core.arr, which used to hold everything directly.
####################################################################

###################### INEQUALITIES SIMULATOR ##################

fun draw-inequality(points, f, msg-img) block:

  # some constants for drawing, intervals, etc
  STRIP-WIDTH = 400
  STRIP-HEIGHT = 30
  tri = rotate(90, triangle(10, "solid", "black"))
  num-intervals = 10
  c1 = make-color(100, 100, 255, 0.5)
  strip = rectangle(STRIP-WIDTH + 48, STRIP-HEIGHT, "outline", "transparent")
  inequalities-bg = overlay(rectangle(STRIP-WIDTH, 2, "solid", "black"), strip)
  axis = translate(flip-horizontal(tri),
    STRIP-WIDTH + 38, STRIP-HEIGHT / 2,
    translate(tri, 10, STRIP-HEIGHT / 2, inequalities-bg))

  fun num-to-mark(n):
    if num-is-integer(n): num-to-string(n)
    else: num-to-string-digits(n, 2) end
  end

  # given a textcolor, a fn to draw the point, and a projection fn,
  # produce a function that consumes a point and an image, then draws
  # a dot of that color
  fun dot-builder(draw-point, project, shadow points, base):
    points.foldl(
      lam(p, img):
        translate(draw-point(p), project(p) + 24, STRIP-HEIGHT / 2, img)
      end,
      base)
  end

  # build a strip of labeled points
  fun label-builder(project, shadow points, alignment, c):
    points.foldl(
      lam(p, img):
        translate(
          overlay-align("center", alignment,
            rotate(90, text(num-to-mark(p), 10, c)),
            square(30, "solid", "transparent")),
          project(p) + 24, STRIP-HEIGHT / 2,
          img)
      end,
      strip)
  end

  # given an inequality fn and a reverse-projection fn, test every pixel
  # on a 600px range and mark "true" pixels as transparent blue
  fun draw-shade(rProject, c):
    range-by(0, STRIP-WIDTH, 2).foldl(lam(p, img):
        shadow color = if f(rProject(p)): c else: "transparent" end
        beside(img, rectangle(2, 15, "solid", color))
      end,
      rectangle(0,0,"solid","transparent"))
  end

  # find the start and stop of the range
  start = Math.min(points)
  stop = Math.max(points)
  # given one of the points on the range, project to pixels on the axis
  fun project(p): (p - start) * (STRIP-WIDTH / (stop - start)) end
  # given a pixel on the axis, reverse-project back to a point on the range
  fun rProject(p): (p / (STRIP-WIDTH / (stop - start))) + start end
  # make a list of all the interval coordinates
  intervals = range-by(start, stop, (stop - start) / num-intervals)
  # make a strip containing all those intervals
  intervals-strip = label-builder(project, intervals, "top", "darkgray")
  # make a strip containing all the points
  points-strip = label-builder(project, points, "bottom", "black")
  # starting with the blank axis, add the shade...
  axis-strip = translate(draw-shade(rProject, c1),
    (STRIP-WIDTH + 50) / 2, STRIP-HEIGHT / 2, axis)
  # add the interval dots
  black-dots-strip = dot-builder(lam(p): circle(2, "solid", "black") end, project, intervals, axis-strip)
  # add the points
  dots-strip = dot-builder(lam(p): translate(
        text(if f(p): "T" else: "F" end, 10, "black"),
        10, 8,
      circle(10, "solid", if f(p): "green" else: "red" end)) end,
    project, points, black-dots-strip)
  when (points.length() <> 8):
    raise("the list must contain exactly 8 points")
  end
  above-list([list: strip, points-strip, dots-strip, intervals-strip, msg-img])
end

# given a list of numbers and an inequality function,
# check to see if the list contains 8 elements, then graph
# the inequality and the points on a numberline
# report back which points passed
fun inequality(f, points):
  passed = points.foldl(lam(p, shadow count): (if f(p): count + 1 else: count end) end, 0)
  msg-img = if (passed == 4):
    text(" ", 20, "green")
  else: text("Challenge yourself: Find 4 true examples and 4 false", 20, "red")
  end
  draw-inequality(points, f, msg-img)
end

fun or-union(f1, f2, points):
  msg-img = text("All regions shaded blue are part of the solution", 20, "blue")
  overlay-align(
    "center", "top",
    text("UNION", 20, "black"),
    draw-inequality(points, lam(x): f1(x) or f2(x) end, msg-img))
end

fun and-intersection(f1, f2, points):
  start = Math.min(points)
  stop = Math.max(points)
  f = lam(x): f1(x) and f2(x) end
  has-intersection = L.any(f, range-by(0, 600, 1))
  msg-img = if has-intersection:
    text("All regions shaded blue are part of the solution", 20, "blue")
  else: text("No solution exists within this range!", 20, "blue")
  end
  overlay-align(
    "center", "top",
    text("INTERSECTION", 20, "black"),
    draw-inequality(points, lam(x): f1(x) and f2(x) end, msg-img))
end



################################################################
############### PERMUTATIONS AND COMBINATIONS ##################
factorial :: (n :: NumNonNegative) -> Number
fun factorial(n):
  if (n <= 1): 1
  else: n * factorial(n - 1)
  end
end

permute-wo-replace :: <A>(items :: L.List<A>, choose :: Number) -> L.List<List<A>>
fun permute-wo-replace(items, choose):
  if items.length() == 0: [list:]
  else if choose == 0: [list:]  # nothing to choose -> empty list
  else if choose == 1: items.map(lam(e): [list: e] end)
  else:
    items.foldl(lam(e, acc):
        rest = permute-wo-replace(items.remove(e), choose - 1).map(lam(p):
          link(e, p) end)
        acc.append(rest)
      end,
      [list:])
  end
end


permute-w-replace :: <A>(items :: L.List<A>, choose :: Number) -> L.List<List<A>>
fun permute-w-replace(items, choose):
  if items.length() == 0: [list:]
  else if choose == 0: [list:]
  else if choose == 1: items.map(lam(e): [list: e] end)
  else:
    items.foldl(lam(e, acc):
        rest = permute-w-replace(items, choose - 1).map(lam(p):
          link(e, p) end)
        acc.append(rest)
      end,
      [list:])
  end
end

combine-wo-replace :: <A>(items :: L.List<A>, choose :: Number) -> L.List<List<A>>
# from https://rosettacode.org/wiki/Combinations#Pyret
fun combine-wo-replace(items, choose):
  if items.length() < choose:
    raise(Err.message-exception("The list must be at least as long as the number of choices"))
  else if items.length() == choose: [list: items]
  else if choose == 1: items.map(lam(e): [list: e] end)
  else:
    # The main resursive step here is to consider
    # all the combinations of the list that have the
    # first element (aka head) and then those that don't
    # don't.
    cases(List) items:
      | empty => [list:]
      | link(first, rest) =>
        # All the subsets of our list either include the
        # first element of the list or they don't.
        with-first = combine-wo-replace(rest, choose - 1).map(
          lam(c): link(first, c) end)
        without-first = combine-wo-replace(rest, choose)
        with-first.append(without-first)
    end
  end
end

render-list :: (lst :: L.List) -> Image
fun render-list(lst):
  lst-imgs = lst.map(lam(l):
      elt-imgs = l.map(lam(e):
          if is-image(e): e
          else if is-string(to-repr(e)): text(e, 12, "black")
          else: to-repr(e)
          end
        end)
      beside-list(elt-imgs)
    end)
  unspoken-img(above-list(lst-imgs))
end

fun whats-missing(answer, test):
  answer-set = Sets.list-to-set(answer)
  test-set = Sets.list-to-set(test)
  diff = answer-set.difference(test-set)
  if diff.size() > 0: diff.to-list()
  else: "You got them all!"
  end
end

fun unspoken-img(img): color-list-to-image(image-to-color-list(img), image-width(img), image-height(img), image-pinhole-x(img), image-pinhole-y(img)) end


#########################################################
# Image transformation functions

# print-imgs :: (img-lst :: L.List<Image>) -> Image
# maximize height and add padding to each image, then
# sort them in order of decreasing heights
# stick them together until we hit 500px,
# then start a new row
fun print-imgs(img-lst) block:

  # how much padding to put around each image (in px)
  padding = 10

  fun img-compare(img1, img2):
    (image-height(img1) >= image-height(img2)) and
    (image-width(img1) > image-width(img2))
  end
  fun img-eq(img1, img2):
    image-height(img1) == image-height(img2)
  end

  # if an image is wider than it is tall, rotate it 90°
  fun maximize-height(img):
    if (image-height(img) > image-width(img)): img
    else: rotate(90, img)
    end
  end
  # Add an extra padding on either side an image
  fun add-padding(img):
    w = image-width(img) + padding
    h = image-height(img) + padding
    overlay(img, rectangle(w, h, "solid", "transparent"))
  end
  fun add-dimensions(img):
    w = image-width(img)
    h = image-height(img)
    wS = num-to-string(w)
    hS = num-to-string(h)
    txt = text([list:wS, "x", hS].join-str(""), 100, "black")
    scaled-txt = if (image-width(img) > image-height(img)):
      scale(0.5, scale(w / image-width(txt), txt))
    else:
      rotate(90, scale(0.5, scale(w / image-height(txt), txt)))
    end
    translate(
      scaled-txt,
      (w / 2),
      (h / 2),
      img)
  end


  # if it's the first image, just add it
  # otherwise grab the last row, and see if we can add the image
  # if not, start a new row
  fun processor(img, acc):
    if (acc.length() == 0): acc.push(img)
    else:
      var split = L.split-at(1,acc)
      var lastRow = split.prefix.last()
      if ((image-width(lastRow) + image-width(img)) > 500):
        acc.push(img)
      else:
        split.suffix.push(beside(lastRow,img))
      end
    end
  end

  img-lst
    .map(maximize-height)
    .sort-by(img-compare, img-eq)
    .map(add-dimensions)
    .map(add-padding)
    .foldl(processor, [list:])
    .foldl(lam(img, acc): below(img, acc) end,
    square(padding,"solid","transparent"))
end


