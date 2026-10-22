use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/fall2026/libraries", "self-driving-car-library.arr")
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
  trim(recorded, "offset", 1, 3).get-column("id") is [list: 1, 2, 3]
  sample-rows(recorded, 2).get-column("id") is [list: 0, 2, 4]
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
