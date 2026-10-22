use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/libraries", "self-driving-car-library.arr")
import tables as Tables

# a circular track: radius 200 about (400, 300), starting at (600, 300), heading straight "down" the screen
circ = track-params(200, 0, 200, 0, 0, 0, 0)
# a wiggly track with every harmonic switched on
wig = track-params(200, 50, 120, 30, 0, 0, 0)
fun on-track-car(trk, t-i):
  t = (t-i / 480) * 2 * PI
  car(track-cx(trk, t), track-cy(trk, t), track-heading(trk, t), true, 2.0, 0, 0, 0, 0, false, false, t-i)
end
start-car = on-track-car(circ, 0)

check "wrap-angle and approach":
  wrap-angle(0) is-roughly 0
  wrap-angle(PI + 0.1) is-roughly (0.1 - PI)
  wrap-angle((0 - PI) - 0.1) is-roughly (PI - 0.1)
  approach(0, 10, 3) is 3
  approach(9, 10, 3) is 10
  approach(0, -10, 3) is -3
end

check "track geometry":
  track-cx(wig, 0) is-roughly 650
  track-cy(wig, 0) is-roughly 300
  track-heading(wig, 0) is-roughly (PI / 2)
  # the track is a closed loop
  track-cx(wig, 2 * PI) is-roughly track-cx(wig, 0)
  track-cy(wig, 2 * PI) is-roughly track-cy(wig, 0)
end

check "check-track":
  check-track(circ) is true
  check-track(track-params(200, 20, 150, 15, 0.5, 0, 0)) is true
  # wig has so much wiggle in it that it is too sharp to be a valid track
  check-track(wig) is false
  check-track(track-params(10, 300, 10, 300, 0, 0, 0)) is false
  check-track(random-track()) is true
  check-track(random-track()) is true
  check-track(random-track()) is true
end

check "sensors":
  # offset is positive to the driver's right: at the start the car faces down the screen,
  # so its right-hand side is toward smaller x
  offset-at-t(circ, 590, 300, 0) is-roughly 10
  offset-at-t(circ, 610, 300, 0) is-roughly -10
  offset-at-t(circ, 600, 300, 0) is-roughly 0
  # a circle turns 1 radian per unit of t
  sharpness-at-t(circ, 0) is-roughly 1
  # skew is positive when the car points to the right of the track
  skew-at-t(circ, 0, (PI / 2) + 0.1) is-roughly (0.1 * (180 / PI))
  skew-at-t(circ, 0, (PI / 2) - 0.1) is-roughly (0 - (0.1 * (180 / PI)))
  skew-at-t(circ, 0, PI / 2) is-roughly 0
end

check "closest-t-near":
  closest-t-near(wig, track-cx(wig, PI), track-cy(wig, PI), 235) is 240
  closest-t-near(wig, track-cx(wig, PI), track-cy(wig, PI), 245) is 240
  # the search window wraps around the start line, in both directions
  closest-t-near(wig, track-cx(wig, 2 * PI * (2 / 480)), track-cy(wig, 2 * PI * (2 / 480)), 475) is 2
  closest-t-near(wig, track-cx(wig, 2 * PI * (477 / 480)), track-cy(wig, 2 * PI * (477 / 480)), 3) is 477
  # agrees with the full search
  (closest-t(wig, 100, 100) / (2 * PI)) * 480 is-roughly closest-t-near(wig, 100, 100, (closest-t(wig, 100, 100) / (2 * PI)) * 480)
end

check "crossed-start":
  crossed-start(470, 3) is true
  crossed-start(3, 470) is false
  crossed-start(100, 101) is false
  crossed-start(101, 100) is false
end

check "make-tick":
  straight = lam(s, sharp, off, he): 0 end
  hard-right = lam(s, sharp, off, he): 90 end
  a = make-tick(circ, straight, false)(start-car)
  # on the centerline and not steering: speed creeps up, the car moves forward along its heading
  a.alive is true
  a.speed-val is-roughly 2.05
  a.x is-roughly (600 + (2.05 * num-cos(PI / 2)))
  a.y is-roughly (300 + 2.05)
  a.heading is-roughly (PI / 2)
  # speed is capped at MAX-SPEED
  make-tick(circ, straight, false)(car(600, 300, PI / 2, true, 3.0, 0, 0, 0, 0, false, false, 0)).speed-val is-roughly 3.0
  # steering past the dead band slows the car, and turns it by angle * STEERING-FACTOR
  b = make-tick(circ, hard-right, false)(car(600, 300, PI / 2, true, 2.5, 0, 0, 0, 0, false, false, 0))
  b.speed-val is-roughly 2.45
  b.heading is-roughly ((PI / 2) + ((PI / 2) * STEERING-FACTOR))
  b.steer-val is 90
  # the steering function sees the sensors, and what it returns is recorded
  seen = make-tick(circ, lam(s, sharp, off, he): off end, false)(car(590, 300, PI / 2, true, 2.0, 0, 0, 0, 0, false, false, 0))
  seen.steer-val is-roughly 10
  seen.offset-val is-roughly 10
  # a dead car does not move
  dead = car(600, 300, PI / 2, false, 2.0, 0, 0, 0, 0, false, false, 0)
  make-tick(circ, straight, false)(dead) is dead
end

check "make-tick off the road":
  straight = lam(s, sharp, off, he): 0 end
  # 50 px to the driver's right of the centerline is off the 45 px half-road
  off-road = car(550, 300, PI / 2, true, 2.5, 0, 0, 0, 0, true, false, 0)
  crashed = make-tick(circ, straight, false)(off-road)
  crashed.alive is false
  crashed.x is 550
  crashed.y is 300
  crashed.offset-val is-roughly 50
  # in survival mode the car is put back on the road, on the same side, facing along the track
  back = make-tick(circ, straight, true)(off-road)
  back.alive is true
  back.offset-val is-roughly (ROAD-HALF-WIDTH * 0.6)
  back.x is-roughly (600 - (ROAD-HALF-WIDTH * 0.6))
  back.y is-roughly 300
  back.heading is-roughly (PI / 2)
  back.skew-val is 0
  back.speed-val is 2.5
  back.key-left is true
  # ...and on the other side when the car left the road on the left
  back-left = make-tick(circ, straight, true)(car(650, 300, PI / 2, true, 2.5, 0, 0, 0, 0, false, false, 0))
  back-left.offset-val is-roughly (0 - (ROAD-HALF-WIDTH * 0.6))
  back-left.x is-roughly (600 + (ROAD-HALF-WIDTH * 0.6))
end

check "game-step":
  g = game(start-car, circ, make-road-image(circ))
  straight = lam(s, sharp, off, he): 0 end
  # an ordinary step keeps the track
  game-step(g, straight, false).trk is circ
  # a dead game does not change
  dead-game = game(car(600, 300, PI / 2, false, 2.0, 0, 0, 0, 0, false, false, 0), circ, g.road-img)
  game-step(dead-game, straight, false) is dead-game
  # crossing the start line starts a fresh car on a new, valid track, keeping the held keys
  near-end = game(car(track-cx(circ, 2 * PI * (1 / 480)), track-cy(circ, 2 * PI * (1 / 480)), PI / 2, true,
      3.0, 0, 0, 0, 0, true, false, 479), circ, g.road-img)
  next = game-step(near-end, straight, false)
  next.car.t-prev is 0
  next.car.speed-val is CAR-SPEED
  next.car.key-left is true
  check-track(next.trk) is true
  next.car.x is-roughly track-cx(next.trk, 0)
  next.car.y is-roughly track-cy(next.trk, 0)
end

check "ramp-steering":
  ramp-steering(car(0, 0, 0, true, 2, 0, 0, 0, 0, true, false, 0), 0, 0, 0) is -8
  ramp-steering(car(0, 0, 0, true, 2, 0, 0, 0, 0, false, true, 0), 0, 0, 0) is 8
  # pressing both keys, or neither, steers back toward center
  ramp-steering(car(0, 0, 0, true, 2, 0, 0, 0, 30, true, true, 0), 0, 0, 0) is 22
  ramp-steering(car(0, 0, 0, true, 2, 0, 0, 0, -30, false, false, 0), 0, 0, 0) is -22
  # the wheel never goes past MAX-STEER
  ramp-steering(car(0, 0, 0, true, 2, 0, 0, 0, 86, false, true, 0), 0, 0, 0) is MAX-STEER
end

check "handle-train-key":
  c = car(0, 0, 0, true, 2, 0, 0, 0, 0, false, false, 7)
  handle-train-key(c, {action: "keydown", key: "left"}).key-left is true
  handle-train-key(c, {action: "keydown", key: "right"}).key-right is true
  handle-train-key(car(0, 0, 0, true, 2, 0, 0, 0, 0, true, false, 7), {action: "keyup", key: "left"}).key-left is false
  # other keys are ignored
  handle-train-key(c, {action: "keydown", key: "up"}) is c
  # escape ends the session
  handle-train-key(c, {action: "keydown", key: "escape"}).alive is false
  handle-train-key(c, {action: "keyup", key: "escape"}).alive is true
  # the key handler keeps the car's position in the track
  handle-train-key(c, {action: "keydown", key: "left"}).t-prev is 7
end

check "states-to-table records the speed the model saw":
  # each state's speed-val is the speed AFTER its tick's update, so the recorded
  # speed lags by one row; the first row uses its own speed
  s0 = car(0, 0, 0, true, 2.0, 0,   0,   0,   0, false, false, 0)
  s1 = car(0, 0, 0, true, 2.5, 0.1, 5,   3,  20, false, false, 1)
  s2 = car(0, 0, 0, true, 2.45, 0.2, 6, 4, 25, false, false, 2)
  t = states-to-table([list: 10, 11, 12], [list: s0, s1, s2])
  t.column-names() is [list: "id", "speed", "curve", "offset", "skew", "steering-angle"]
  t.get-column("id") is [list: 10, 11, 12]
  t.get-column("speed") is [list: 2.0, 2.0, 2.5]
  t.get-column("curve") is [list: 0, 0.1, 0.2]
  t.get-column("offset") is [list: 0, 5, 6]
  t.get-column("skew") is [list: 0, 3, 4]
  t.get-column("steering-angle") is [list: 0, 20, 25]
end

check "post-processing":
  moving-average([list: 1, 2, 3, 4, 5], 3) is [list: 3/2, 2, 3, 4, 9/2]
  moving-average([list: 1, 2, 3], 1) is [list: 1, 2, 3]
  moving-average([list: 4, 4, 4, 4], 5) is [list: 4, 4, 4, 4]
  recorded = [Tables.table-from-columns:
    {"id"; [list: 0, 1, 2, 3, 4]}, {"speed"; [list: 2, 2, 2, 2, 2]}, {"curve"; [list: 0, 0, 0, 0, 0]},
    {"offset"; [list: 0, 1, 2, 3, 4]}, {"skew"; [list: 0, 0, 0, 0, 0]},
    {"steering-angle"; [list: 0, 0, 10, 0, 0]}]
  smooth(recorded).get-column("steering-angle") is [list: 10/3, 5/2, 2, 5/2, 10/3]
  smooth(recorded).get-column("offset") is [list: 0, 1, 2, 3, 4]
  smooth(recorded).length() is 5
  # trim(recorded, "offset", 1, 3).get-column("id") is [list: 1, 2, 3]
  # sample-rows(recorded, 2).get-column("id") is [list: 0, 2, 4]
end

check "drawing":
  trk = circ
  road = make-road-image(trk)
  image-width(road) is WIDTH
  image-height(road) is HEIGHT
  image-width(draw-car(start-car, "red", "darkred", empty-image, "CRASHED", road)) is WIDTH
  image-height(draw-car(start-car, "red", "darkred", empty-image, "CRASHED", road)) is HEIGHT
  # the crash message is only drawn for a dead car, and nothing else changes
  dead = car(600, 300, PI / 2, false, 2.0, 0, 0, 0, 0, false, false, 0)
  image-width(draw-car(dead, "red", "darkred", empty-image, "CRASHED", road)) is WIDTH
  image-width(draw-pov(start-car, trk, empty-image, "x")) is WIDTH
  image-height(draw-pov(start-car, trk, empty-image, "x")) is HEIGHT
  image-width(add-banner-pov(draw-pov(start-car, trk, empty-image, "x"), start-car, trk)) is WIDTH
  image-width(add-banner-birds-eye(road, trk)) is WIDTH
end

check "drive checks its predictor":
  drive(lam(n): n + 1 end) raises "consumes Rows"
end

# ---- cleaning a training run ----

fun ints(n :: Number):
  if n <= 0: empty else: ints(n - 1) + [list: n - 1] end
end
fun mk-table(ids, curves, offsets, skews, steers):
  [Tables.table-from-columns:
    {"id"; ids}, {"speed"; ids.map({(_): 2.5})}, {"curve"; curves},
    {"offset"; offsets}, {"skew"; skews}, {"steering-angle"; steers}]
end
fun mk-row(c, o, k, s):
  [Tables.raw-row: {"id"; 0}, {"speed"; 2.5}, {"curve"; c}, {"offset"; o}, {"skew"; k}, {"steering-angle"; s}]
end
fun spread(xs): xs.foldl(num-max, xs.first) - xs.foldl(num-min, xs.first) end

check "is-junk-row":
  # the car's starting state
  is-junk-row(mk-row(0, 0, 0, 0)) is true
  # a car that was put back on the road, on either side
  is-junk-row(mk-row(1.5, SNAP-BACK-OFFSET, 0, 30)) is true
  is-junk-row(mk-row(1.5, 0 - SNAP-BACK-OFFSET, 0, 30)) is true
  # ordinary driving, including driving straight or at the same offset with some skew
  is-junk-row(mk-row(1.5, 3, 4, 30)) is false
  is-junk-row(mk-row(0, 0, 0, 10)) is false
  is-junk-row(mk-row(1.5, SNAP-BACK-OFFSET, 1.5, 30)) is false
end

check "drop-junk-rows":
  t = mk-table([list: 0, 1, 2, 3], [list: 1, 0, 2, 3], [list: 5, 0, 27, -4], [list: 3, 0, 0, 2], [list: 20, 0, 40, 10])
  drop-junk-rows(t).get-column("id") is [list: 0, 3]
end

check "every-nth-row":
  # by position, not by id
  every-nth-row(mk-table(ints(7), ints(7), ints(7), ints(7), ints(7)), 3).get-column("id") is [list: 0, 3, 6]
  every-nth-row(mk-table([list: 0, 1, 5, 6, 9], [list: 1, 1, 1, 1, 1], [list: 1, 1, 1, 1, 1], [list: 1, 1, 1, 1, 1], [list: 1, 1, 1, 1, 1]), 3).get-column("id") is [list: 0, 6]
  every-nth-row(mk-table([list: 0, 1], [list: 1, 1], [list: 1, 1], [list: 1, 1], [list: 1, 1]), 5).get-column("id") is [list: 0]
end

check "renumber-rows":
  renumber-rows(mk-table([list: 4, 9, 12], [list: 1, 2, 3], [list: 4, 5, 6], [list: 7, 8, 9], [list: 1, 2, 3])).get-column("id") is [list: 0, 1, 2]
end

check "pull-toward-bin-average":
  # two slices of curve (0 and 10) with three rows each, plus a lone row at 5 that gets dropped
  t = mk-table(ints(7), [list: 0, 0, 0, 10, 10, 10, 5], [list: 1, 2, 3, 4, 5, 6, 7], [list: 1, 1, 1, 1, 1, 1, 1],
    [list: 10, 20, 30, -10, -20, -30, 99])
  # each steering angle moves 3/4 of the way to its slice average (20 and -20)
  pull-toward-bin-average(t, 3/4).get-column("steering-angle") is [list: 35/2, 20, 45/2, -35/2, -20, -45/2]
  pull-toward-bin-average(t, 0).get-column("steering-angle") is [list: 10, 20, 30, -10, -20, -30]
  pull-toward-bin-average(t, 1).get-column("steering-angle") is [list: 20, 20, 20, -20, -20, -20]
  # only the steering angle changes, and the thin slice is gone
  pull-toward-bin-average(t, 3/4).get-column("id") is [list: 0, 1, 2, 3, 4, 5]
  pull-toward-bin-average(t, 3/4).get-column("curve") is [list: 0, 0, 0, 10, 10, 10]
  pull-toward-bin-average(t, 3/4).get-column("offset") is [list: 1, 2, 3, 4, 5, 6]
  # nothing to bin: one row, no spread in curve, or no slice with enough rows
  single = mk-table([list: 0], [list: 1], [list: 1], [list: 1], [list: 50])
  pull-toward-bin-average(single, 3/4) is single
  flat = mk-table([list: 0, 1, 2], [list: 2, 2, 2], [list: 1, 1, 1], [list: 1, 1, 1], [list: 10, 20, 90])
  pull-toward-bin-average(flat, 3/4) is flat
  pull-toward-bin-average(mk-table([list: 0, 1, 2, 3], [list: 0, 5, 10, 15], [list: 1, 1, 1, 1], [list: 1, 1, 1, 1], [list: 1, 2, 3, 4]), 3/4).length() is 0
end

check "clean-training-table":
  n = 60
  ids = ints(n)
  curves = ids.map({(i): if num-modulo(i, 2) == 0: -1 else: 1 end})
  steers = ids.map({(i): if num-modulo(i, 2) == 0: 60 + (5 * num-modulo(i, 7)) else: -60 - (5 * num-modulo(i, 5)) end})
  offsets = ids.map({(i): num-modulo(i, 10) - 5})
  skews = ids.map({(i): 1 + num-modulo(i, 3)})
  # a starting-state row at the front, and a snapped-back row in the middle
  raw = mk-table(ids,
    ids.map({(i): if i == 0: 0 else: curves.get(i) end}),
    ids.map({(i): if i == 30: SNAP-BACK-OFFSET else if i == 0: 0 else: offsets.get(i) end}),
    ids.map({(i): if (i == 30) or (i == 0): 0 else: skews.get(i) end}),
    ids.map({(i): if i == 0: 0 else: steers.get(i) end}))
  cleaned = clean-training-table(raw)
  cleaned.column-names() is [list: "id", "speed", "curve", "offset", "skew", "steering-angle"]
  # a third of the rows, minus the junk, numbered from zero
  (cleaned.length() >= 15) and (cleaned.length() <= 25) is true
  cleaned.get-column("id") is ints(cleaned.length())
  cleaned.filter(lam(r): is-junk-row(r) end).length() is 0
  # the steering angles are pulled together
  (spread(cleaned.get-column("steering-angle")) < spread(raw.get-column("steering-angle"))) is true
  # pulling toward the average for each curve keeps the steering on the side its curve calls for
  bins-only = clean-training-table-with(raw, "curve-bins")
  bins-only.filter(lam(r): (r["curve"] < 0) and (r["steering-angle"] < 0) end).length() is 0
  bins-only.filter(lam(r): (r["curve"] > 0) and (r["steering-angle"] > 0) end).length() is 0
end

# how far apart two lists of numbers are (the balanced plane makes roughnums, which can't be compared with ==)
fun max-diff(a, b): map2(lam(x, y): num-abs(x - y) end, a, b).foldl(num-max, 0) end

fun var-of(xs):
  n = xs.length()
  m = xs.foldl(lam(x, acc): acc + x end, 0) / n
  xs.map(lam(x): (x - m) * (x - m) end).foldl(lam(x, acc): acc + x end, 0) / n
end

# steering = 1 + 2*curve + 3*offset + noise, where the noise is exactly orthogonal to
# (1, curve, offset), so the least-squares plane is exactly 1 + 2*curve + 3*offset
_plane-curve = [list: 0, 1, 2, 3, 0, 1, 2, 3]
_plane-offset = [list: 0, 0, 0, 0, 1, 1, 1, 1]
_plane-noise = [list: 1, -1, -1, 1, -1, 1, 1, -1]
_plane-t = mk-table(ints(8), _plane-curve, _plane-offset, [list: 1, 1, 1, 1, 1, 1, 1, 1],
  [list: 2, 2, 4, 8, 3, 7, 9, 9])

check "plane-fit":
  fit = plane-fit(_plane-t)
  fit.{0} is true
  fit.{1} is 2
  fit.{2} is 3
  # no plane to fit: too few rows, no variation, or curve and offset in lockstep
  plane-fit(mk-table([list: 0, 1], [list: 0, 1], [list: 0, 1], [list: 0, 0], [list: 1, 2])).{0} is false
  plane-fit(mk-table(ints(4), [list: 2, 2, 2, 2], [list: 0, 1, 2, 3], [list: 0, 0, 0, 0], [list: 1, 2, 3, 4])).{0} is false
  plane-fit(mk-table(ints(4), [list: 0, 1, 2, 3], [list: 5, 5, 5, 5], [list: 0, 0, 0, 0], [list: 1, 2, 3, 4])).{0} is false
  plane-fit(mk-table(ints(4), [list: 0, 1, 2, 3], [list: 0, 2, 4, 6], [list: 0, 0, 0, 0], [list: 1, 2, 3, 4])).{0} is false
end

check "pull-toward-plane, best fit":
  # the plane is 1, 3, 5, 7, 4, 6, 8, 10 and the noise around it is +1 or -1, so a 3/4 pull leaves a quarter of it
  pull-toward-plane(_plane-t, 3/4, false).get-column("steering-angle") is
  [list: 5/4, 11/4, 19/4, 29/4, 15/4, 25/4, 33/4, 39/4]
  pull-toward-plane(_plane-t, 1, false).get-column("steering-angle") is [list: 1, 3, 5, 7, 4, 6, 8, 10]
  pull-toward-plane(_plane-t, 0, false).get-column("steering-angle") is _plane-t.get-column("steering-angle")
  # only the steering angle changes
  pull-toward-plane(_plane-t, 3/4, false).get-column("curve") is _plane-curve
  pull-toward-plane(_plane-t, 3/4, false).get-column("id") is ints(8)
  # a model fit to the pulled data is the same plane
  plane-fit(pull-toward-plane(_plane-t, 3/4, false)).{1} is 2
  plane-fit(pull-toward-plane(_plane-t, 3/4, false)).{2} is 3
  # nothing to fit: the table comes back unchanged
  pull-toward-plane(mk-table([list: 0, 1], [list: 0, 1], [list: 0, 1], [list: 0, 0], [list: 1, 2]), 3/4, false).get-column("steering-angle") is [list: 1, 2]
end

check "pull-toward-plane, balanced":
  full = pull-toward-plane(_plane-t, 1, true)
  slopes = plane-fit(full)
  # curve varies 1.25 and offset 0.25, so equal shares of the 7.25 explained need slopes sqrt(2.9) and sqrt(14.5)
  slopes.{1} is-roughly num-sqrt(29 / 10)
  slopes.{2} is-roughly num-sqrt(29 / 2)
  # each sensor now explains the same variance, and the total explained is unchanged
  var-of(_plane-curve.map({(c): slopes.{1} * c })) is-roughly var-of(_plane-offset.map({(o): slopes.{2} * o }))
  var-of(_plane-curve.map({(c): slopes.{1} * c })) + var-of(_plane-offset.map({(o): slopes.{2} * o })) is-roughly 29/4
  # the tilt keeps its direction in each sensor
  down = mk-table(ints(8), _plane-curve, _plane-offset, [list: 1, 1, 1, 1, 1, 1, 1, 1],
    [list: -2, -4, -6, -6, -9, -9, -13, -15])
  down-slopes = plane-fit(pull-toward-plane(down, 1, true))
  (down-slopes.{1} < 0) is true
  (down-slopes.{2} < 0) is true
  # at strength 0 nothing moves
  pull-toward-plane(_plane-t, 0, true).get-column("steering-angle") is _plane-t.get-column("steering-angle")
end

_cm-ids = ints(60)
_cm-curves = _cm-ids.map({(i): if num-modulo(i, 2) == 0: -1 else: 1 end})
_cm-offsets = _cm-ids.map({(i): num-modulo(i, 10) - 5})
_cm-steers = _cm-ids.map({(i): if num-modulo(i, 2) == 0: 60 + (5 * num-modulo(i, 7)) else: -60 - (5 * num-modulo(i, 5)) end})
# skew repeats every 4 rows, so it still varies after every 3rd row is kept
_cm-raw = mk-table(_cm-ids, _cm-curves, _cm-offsets, _cm-ids.map({(i): 1 + num-modulo(i, 4)}), _cm-steers)

check "clean-training-table methods":
  bins = clean-training-table-with(_cm-raw, "curve-bins")
  best = clean-training-table-with(_cm-raw, "best-fit-plane")
  balanced = clean-training-table-with(_cm-raw, "balanced-plane")
  # every method thins, numbers and keeps the same columns
  [list: bins, best, balanced].map({(t): t.column-names()}) is
  [list: [list: "id", "speed", "curve", "offset", "skew", "steering-angle"], [list: "id", "speed", "curve", "offset", "skew", "steering-angle"], [list: "id", "speed", "curve", "offset", "skew", "steering-angle"]]
  best.get-column("id") is ints(best.length())
  balanced.get-column("id") is ints(balanced.length())
  # the planes keep every thinned row (the bin method may drop thin slices)
  best.length() is balanced.length()
  best.length() is bins.length()
  # the three methods give different steering angles
  (max-diff(best.get-column("steering-angle"), bins.get-column("steering-angle")) > 0.001) is true
  (max-diff(best.get-column("steering-angle"), balanced.get-column("steering-angle")) > 0.001) is true
  (max-diff(balanced.get-column("steering-angle"), bins.get-column("steering-angle")) > 0.001) is true
  # the switch is the constant: the default is the balanced plane
  CLEANUP-METHOD is "balanced-plane"
  default = clean-training-table(_cm-raw)
  (max-diff(default.get-column("steering-angle"), balanced.get-column("steering-angle")) < 0.000001) is true
  default.get-column("id") is balanced.get-column("id")
  default.get-column("curve") is balanced.get-column("curve")
  # a bad name says what is allowed
  clean-training-table-with(_cm-raw, "nonsense") raises "CLEANUP-METHOD must be"
end

check "cleanup settings":
  CLEANUP-METHOD is "balanced-plane"
  CLEANUP-STRENGTH is 17/20
  CLEANUP-BINS is 20
  CLEANUP-MIN-BIN is 3
  CLEANUP-KEEP-EVERY is 3
end

# the recipe in ai/Self-Driving-Car.arr: fit models to the cleaned table, then look at what is left over
check "the starter file's leftover-variability recipe works on a cleaned table":
  d = clean-training-table(_cm-raw)
  curve-fit = regression-model-fun(d, [list: "curve"], "steering-angle")
  leftover = build-column(d, "steering (curve removed)", lam(r): r["steering-angle"] - curve-fit(r) end)
  leftover.column-names() is (d.column-names() + [list: "steering (curve removed)"])
  leftover.length() is d.length()
  # least-squares residuals add up to zero
  leftover.get-column("steering (curve removed)").foldl(lam(x, acc): acc + x end, 0) is-roughly 0
  # each model that adds a sensor can only leave less unexplained
  fun unexplained(cols):
    fit = regression-model-fun(d, cols, "steering-angle")
    d.all-rows().map(lam(r): (r["steering-angle"] - fit(r)) * (r["steering-angle"] - fit(r)) end).foldl(lam(x, acc): acc + x end, 0)
  end
  (unexplained([list: "curve", "offset"]) <= (unexplained([list: "curve"]) + 0.000001)) is true
  (unexplained([list: "curve", "offset", "skew"]) <= (unexplained([list: "curve", "offset"]) + 0.000001)) is true
  # the columns that lr-plot is given in the starter file are all there
  d.column-names().member("id") is true
end
