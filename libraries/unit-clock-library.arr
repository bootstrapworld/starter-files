use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "core.arr")

################################################################
# Bootstrap Unit Clock Library, as of Fall 2026

provide *

# export every symbol from starter2024 except for those we override
import starter2024 as Starter
include from Starter:
  * hiding(translate, filter, range, sort, sin, cos, tan)
end

fun deg-to-rad(d):
  num-exact((d / 180) * PI)
end

fun rad-to-deg(r):
  num-exact((r / PI) * 180)
end

# following vars are user-changeable (in interaction pane)
var radius = 100
deg-incr = 5
var angle-incr = deg-to-rad(deg-incr)
var max-num-revolutions = 2
var cos-fn = lam(ang): num-cos(ang) end
var sin-fn = lam(ang): num-sin(ang) end
var neg-sin-fn = lam(ang): 0 - num-sin(ang) end
var user-fn= lam(ang): 0 end
var x-scaler = rad-to-deg
var notch-radius = 2
var sin-color   = 'green'
var cos-color   = 'blue'
var user-fn-color  = 'transparent'
var axis-color  = 'grey'
var x-axis-len-in-radii = 7.5
var x-axis-num-quadrants = 9
var x-axis-len = x-axis-len-in-radii * radius
var clock-color = 'black'
var _clock-circumference = 0
var _clock-interval = 1
var _clock-wise = true
var _clock-start = true
var draw-moving-line-p = true

fun make-number-sign(label):
  text(label, 12, 'black')
end

fun make-clock-number-sign(n):
  # n = num of quadrants
  text(notch-num-to-label(n), 20, clock-color)
end

fun clock-hop(n):
  n + angle-incr
end

fun rad-to-abscissa(r):
  ((r / (PI / 2)) / x-axis-num-quadrants) * x-axis-len
end

fun notch-num-to-label(n2) block:
  # n2 is the number of quadrants clockwise from the top;
  # find the label corresponding to it
  n = num-modulo(n2, 4)
  # for a clock circumference that's a multiple of 2π, use π-based labels rather than actual numbers
  num-pis-in-circ = num-exact(_clock-circumference / PI)
  if num-is-integer(num-pis-in-circ) block:
    coeff = n * (num-pis-in-circ / 4)
    # spy: coeff end
    if coeff == 0: "0"
    else if num-is-integer(coeff):
      if coeff == 1: "π"
      else: num-to-string(coeff) + "π"
      end
    else if num-is-integer(2 * coeff):
      coeff2 = 2 * coeff
      if coeff2 == 1: "π/2"
      else: num-to-string(coeff2) + "π/2"
      end
    else:
      coeff4 = 4 * coeff
      if coeff4 == 1: "π/4"
      else: num-to-string(coeff4) + "π/4"
      end
    end
  else if num-is-integer(_clock-circumference) and (num-modulo(_clock-circumference, 4) == 0):
    # for 4-divisible cirumference (e.g., a real clock), use integral labels
    var n3 = (n / 4) * _clock-circumference
    n3 := num-modulo(n3, _clock-circumference)
    if n3 == 0:
      num-to-string(_clock-circumference)
    else:
      num-to-string(n3)
    end
  else:
    # for non-4-divisible circumference, use 2 decimal places
    var n3 = (n / 4) * _clock-circumference
    num-to-string-digits(n3, 2)
  end
end

fun draw-coord-curve-onto(theta-range, coord-gen-fn, curve-color, img):
  # Draws the curve onto the given image, assuming the pinhole of the image is at (0, h/2)
  # where h is the height of the image.
  # compute the (x,y) coords for the ends of the minilines making up the graph:
  # abscissa has to account for rectangle swelling leftward by 1 notch-radius;
  # flip the y-value to account for orientation of Pyret's y-axis
  offset = ((_clock-start / _clock-circumference) * 2 * PI)
  proj-range = for map(theta from theta-range):
    theta2 = if _clock-wise: theta else: 0 - theta end
    {rad-to-abscissa(theta) + notch-radius; -1 * coord-gen-fn(theta2 + offset) * radius}
  end
  # spy: proj-range end
  # use proj-range to draw the mini-lines making up the graph
  cases(List) proj-range:
    | empty => raise("No points given!")
    | link(first, rest) =>
      {shadow img; _} = for fold({shadow img; {prev-x; prev-y}} from {img; first}, cur from rest):
        {poynt-x; poynt-y} = cur
        new-img = scene-line(img, prev-x, prev-y + radius, poynt-x, poynt-y + radius, curve-color)
        {new-img; cur}
      end
      if draw-moving-line-p:
        {prev-x; prev-y} = first
        scene-line(img, prev-x, radius, prev-x, prev-y + radius, curve-color)
      else: img
      end
  end
end

fun make-notched-x-axis-line() block:
  var x-axis-line = place-pinhole(0,0, line(x-axis-len, 0, axis-color))
  fuzz = 1
  var notch-range = 0
  if _clock-wise:
    notch-range := range-by(0, x-axis-num-quadrants + fuzz, 1)
  else:
    notch-range := range-by(0, 0 - x-axis-num-quadrants - fuzz, -1)
  end

  notch = circle(notch-radius, 'outline', 'black')

  # for each angle (represented as length on the x-axis), place the notch's pinhole
  # relative to the axis-pinhole by subtracting the "angle length" relative
  # to the center of the circle and add it to x-axis-line
  clock-starting-quadrant = num-modulo((_clock-start / _clock-circumference) * 4, 4)
  # spy: _clock-start, clock-starting-quadrant, notch-range end

  for map(notch-num2 from notch-range) block:
    notch-num = num-modulo(notch-num2 + clock-starting-quadrant, 4)
    # spy: clock-starting-quadrant, notch-num2, notch-num end
    var notch-x = (notch-num2 / x-axis-num-quadrants) * x-axis-len
    if _clock-wise:
      notch-x := notch-x
    else:
      # notch-x is always positive
      notch-x := 0 - notch-x
    end
    # spy 'for loop': notch-num2, notch-num, notch-x end
    x-axis-line := overlay-align(
      'pinhole', 'pinhole',
      # have to notch notch notch-x rightward, so its
      # pH moves notch-x leftward. But remember to
      # account for notch's dimensions, as new pH is calculated
      # from the top-left of its bounding-box, not its radius!
      place-pinhole((-1 * notch-x) + notch-radius, notch-radius, notch),
      x-axis-line)
    var label = make-number-sign(notch-num-to-label(notch-num))
    label := place-pinhole((-1 * notch-x) + notch-radius, notch-radius - 10, label)
    x-axis-line := overlay-align('pinhole', 'pinhole', label, x-axis-line)
  end

  x-axis-line
end

fun draw-clock-and-graph(n):
  # consumes n (radians) and draws an image

  # draw the 1 and -1 for the y-axis, positioning notches
  # at the top and bottom of the bounding box
  notch = circle(notch-radius, 'solid', 'black')
  y-axis-labels = overlay-xy(
    beside-align("top",
                 overlay-xy(make-number-sign("1 "),
                 -6, -4,
                 square(20, 'solid','transparent')), notch),
    -3,
    (radius * 2) - 20,
    beside-align("bottom",
                 overlay-xy(make-number-sign("-1"),
                 4, -4,
                 square(20, 'solid','transparent')), notch))

  # assemble the images, overlaying the y-axis labels on the graph
  beside-list([list:
      draw-clock(n),
      rectangle(radius, 0, "outline", "white"),
      square(5, "solid", "transparent"),
      overlay-xy(y-axis-labels, 25, 0, draw-graph(n))
      ])
end

fun draw-clock(n) block:
  # we're only marking NESW points of clock
  clock-points = [list: 0, 1, 2, 3]
  num-clock-points = clock-points.length()
  # compute (x,y) coords of point around the circle
  # Since it's a clock, n=0 is at 12 oc rather than 3 oc.
  # Adjust by subtracting π/2 from n.
  var adj-n = n - (PI / 2)
  if _clock-wise:
    adj-n := adj-n + ((_clock-start / _clock-circumference) * 2 * PI)
  else:
    adj-n := adj-n - ((_clock-start / _clock-circumference) * 2 * PI)
  end
  var x-coord = 0
  if _clock-wise:
    x-coord := cos-fn(adj-n) * radius
  else:
    x-coord := 0 - (cos-fn(adj-n) * radius)
  end
  y-coord = sin-fn(adj-n) * radius
  containing-rect = square(2 * radius, "solid", "white")
  u-circle = circle(radius, 'outline', clock-color)
  placed-labels = for map(clock-point from clock-points) block:
    var clock-x = sin-fn((clock-point / num-clock-points) * -2 * PI) * (radius - 1)
    var clock-y = cos-fn((clock-point / num-clock-points) * 2 * PI) * (radius - 1)
    label-img = make-clock-number-sign(clock-point)
    half-label-width = image-width(label-img) / 2
    half-label-height = image-height(label-img) / 2
    # labels at 12 & 6 oc move left by half
    if (clock-point == 0) or (clock-point == 2) block:
      clock-x := clock-x + half-label-width
    else:
      clock-x := clock-x
    end
    # labels at 3 & 9 oc move up by half
    if (clock-point == 1) or (clock-point == 3) block:
      clock-y := clock-y + half-label-height
    else:
      clock-y := clock-y
    end
    if clock-point == 0 block:
      # label at 12 oc moves down by half
      clock-y := clock-y - half-label-height
    else if clock-point == 1:
      # label at 3 oc moves left by half
      clock-x := clock-x + half-label-width
    else if clock-point == 2:
      # label at 6 oc moves up by half
      clock-y := clock-y + half-label-height
    else:
      # label at 9 oc moves right by half
      clock-x := clock-x - half-label-width
    end
    # the following adjustments are heuristic
    if num-is-integer(_clock-circumference):
      if clock-point == 0 block:
        clock-y := clock-y
      else if clock-point == 1:
        clock-x := clock-x + 12
      else if clock-point == 2:
        clock-y := clock-y + 12
      else:
        clock-x := clock-x
      end
    else:
      if clock-point == 0:
        clock-y := clock-y
      else if clock-point == 1:
        clock-x := clock-x + 18
      else if clock-point == 2:
        clock-y := clock-y + 12
      else:
        clock-x := clock-x + 12
      end
    end
    place-pinhole(clock-x, clock-y, label-img)
  end
  vertical-axis = place-pinhole(0, radius, line(0, radius * 2, axis-color))
  horiz-axis = place-pinhole(radius, 0, line(radius * 2, 0, axis-color))
  r-line = place-pinhole(
  # ensure pinhole at 0,0 end of line
  if x-coord > 0: 0 else: 0 - x-coord end,
    if y-coord > 0: 0 else: 0 - y-coord end,
      line(x-coord, y-coord, 'darkgreen'))
      along-x-drop = place-pinhole(if x-coord > 0: 0 else: 0 - x-coord end, 0 - y-coord, line(x-coord,0, sin-color))
      along-y-drop = place-pinhole(0 - x-coord, if y-coord > 0: 0 else: 0 - y-coord end, line(0,y-coord, cos-color))
    overlay-list([list: u-circle, vertical-axis, horiz-axis, r-line, along-x-drop, along-y-drop]
    + placed-labels + [list: containing-rect])
end

fun draw-graph(n):
  containing-rect = place-pinhole(0, radius, rectangle(x-axis-len, 2 * radius, "outline", "white"))
  # create the x- and y-axis, then add them together
  y-axis-line = place-pinhole(0, radius, line(0, 2 * radius, axis-color))
  x-axis-line = make-notched-x-axis-line()
  fuzz = angle-incr
  axes-lines = overlay(x-axis-line, y-axis-line)
  theta-range = range-by(0, n + fuzz, angle-incr)
  # spy:  theta-range end

  draw-coord-curve-onto(
    theta-range, user-fn, user-fn-color,
    draw-coord-curve-onto(
      theta-range, sin-fn, sin-color,
      draw-coord-curve-onto(
        theta-range, cos-fn, cos-color,
        overlay(axes-lines, containing-rect))))
end

fun stop-clock(n):
  n >= (x-axis-num-quadrants * (PI / 2)) # before crossing to right margin
  # n >= ((max-num-revolutions * 2 * PI) - (deg-incr / 360)) # max-revs
  # n >= (20 * (deg-incr / 360)) # very short, for debugging
  # false # forever
end

fun start-clock(spt, __clock-circumference, __clock-wise, __clock-start) block:
  _clock-wise := __clock-wise
  _clock-start := __clock-start
  _clock-circumference := __clock-circumference

  r = reactor:
    init: 0,
    seconds-per-tick: spt,
    on-tick: clock-hop,
    to-draw: draw-clock-and-graph,
    stop-when: stop-clock
  end
  R.interact(r)
  nothing
end

fun start-clock-fn(spt, slices, f) block:
  user-fn := f
  user-fn-color := 'orange'
  start-clock(spt, slices, true, 12)
end
