use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")
################################################################
# Bootstrap Self-Driving Car Library, as of Fall 2026
provide *
# re-export every symbol from Core
import url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr") as Core
# private module imports
import csv as csv
import tables as Tables
import statistics as Statistics
import lists as Lists
include string-dict
provide from Core:
  *,
  type Posn,
  module Err,
  module Sets,
  module T,
  module SD,
  module R,
  module L,
  module Stats
end
# export every symbol from starter2024 except for those we override
import starter2024 as Starter
provide from Starter:
    * hiding(translate, filter, range, sort, sin, cos, tan)
end
provide from L: * hiding(filter, range, sort), type *, data * end
# ============================================================
# ML-DRIVEN CAR REACTOR
#
# Drives a simulated car around a practice track using a trained
# regression model. The model is any function of the form
#
#     (Row -> Number)
#
# where the row has columns [speed, curve-sharpness, offset,
# heading-error] and the return value is the steering-wheel
# angle in degrees (positive = right).
# ============================================================
# Display Constants
WIDTH           = 800
HEIGHT          = 600
ROAD-HALF-WIDTH =  45       # pixels from centerline to road edge
CAR-LENGTH      =  26
CAR-WIDTH       =  14
TEXT-SPACING    =   2

# Driving Constants
STEERING-FACTOR = 0.035     # converts model degrees -> rad/tick of yaw
LOOKAHEAD       = 0.08      # parameter step for measuring track curvature
MAX-STEER       = 90        # max |steering angle| (degrees) the wheel can reach
STEER-RATE      = 8         # how fast the wheel ramps toward its target each tick
MAX-SHARPNESS   = 6.0       # max |dθ/dt| allowed at any point on the track

# Training-mode auto-assist gains.  When neither arrow key is held,
# the wheel targets a corrective angle computed from the current
# sensors using these coefficients (same shape as the hand-tuned
# stub controller).  Set them all to 0 to turn the assist off and
# go back to "wheel just centres when keys are released."
ASSIST-K-SHARP   = 1.001     # feedforward on track curvature
ASSIST-K-OFFSET  = 0.05      # pull toward the centerline
ASSIST-K-HEADING = 0.001     # rotate back into alignment with the track

# Speed dynamics — speed creeps up toward MAX-SPEED while the wheel
# is within ±STEER-DEAD-BAND of centre, and creeps back down toward
# MIN-SPEED whenever the wheel is turned more sharply than that.
CAR-SPEED       = 2.0       # initial speed; varies between MIN-SPEED and MAX-SPEED at runtime
MIN-SPEED       = 2.0
MAX-SPEED       = 3.0
SPEED-STEP      = 0.05      # how much speed changes per tick
STEER-DEAD-BAND = 15        # |steering| < this counts as "near-straight"

# Closest-t search constants
CLOSEST-T-STEPS  = 480
CLOSEST-T-WINDOW =  10

# POV (driver's view) rendering constants
POV-HORIZON-Y   = 250
POV-FOCAL       = 280
POV-CAM-HEIGHT  =  60
POV-LOOKAHEAD   =  60
POV-STEP        = 0.05
POV-NEAR-D      =  15
# Lap counter — banner counts down from this; track regenerates at 0
LAPS-PER-TRACK  =   2
# ============================================================
# TRACK PARAMETERS
# ============================================================
data TrackParams:
  | track-params(
      a1 :: Number, a2 :: Number,
      b1 :: Number, b2 :: Number,
      ph :: Number,
      qx :: Number,
      qy :: Number)
end
fun check-track(trk :: TrackParams) -> Boolean block:
  SAMPLES = 120
  fun verify(i :: Number) -> Boolean:
    if i >= SAMPLES:
      true
    else:
      t     = (i / SAMPLES) * 2 * PI
      sharp = num-abs(
        wrap-angle(track-heading(trk, t + LOOKAHEAD) - track-heading(trk, t)) / LOOKAHEAD)
      if sharp > MAX-SHARPNESS:
        false
      else:
        verify(i + 1)
      end
    end
  end
  verify(0)
end
fun random-track() -> TrackParams:
  trk = track-params(
    150 + num-random(101),
     20 + num-random(51),
    100 + num-random(81),
     15 + num-random(46),
    num-random(629) / 100,
    num-random(629) / 100,
    num-random(629) / 100)
  if check-track(trk): trk
  else: random-track()
  end
end
# ============================================================
# TRACK CENTERLINE
# ============================================================
fun track-cx(trk :: TrackParams, t :: Number) -> Number:
  (WIDTH / 2) + (trk.a1 * num-cos(t + trk.ph)) + (trk.a2 * num-cos((3 * t) + trk.qx))
end
fun track-cy(trk :: TrackParams, t :: Number) -> Number:
  (HEIGHT / 2) + (trk.b1 * num-sin(t + trk.ph)) + (trk.b2 * num-sin((2 * t) + trk.qy))
end
fun track-dx(trk :: TrackParams, t :: Number) -> Number:
  (0 - (trk.a1 * num-sin(t + trk.ph))) + (0 - (3 * trk.a2 * num-sin((3 * t) + trk.qx)))
end
fun track-dy(trk :: TrackParams, t :: Number) -> Number:
  (trk.b1 * num-cos(t + trk.ph)) + (2 * trk.b2 * num-cos((2 * t) + trk.qy))
end
fun track-heading(trk :: TrackParams, t :: Number) -> Number:
  num-atan2(track-dy(trk, t), track-dx(trk, t))
end
fun wrap-angle(a :: Number) -> Number:
  ask:
    | a > PI       then: a - (2 * PI)
    | a < (0 - PI) then: a + (2 * PI)
    | otherwise:   a
  end
end
fun approach(current :: Number, target :: Number, max-step :: Number) -> Number:
  diff = target - current
  if num-abs(diff) <= max-step: target
  else if diff > 0: current + max-step
  else: current - max-step
  end
end
# ============================================================
# CLOSEST-T SEARCH
# ============================================================
fun closest-t(trk :: TrackParams, px :: Number, py :: Number) -> Number:
  fun search(i :: Number, best-t :: Number, best-d2 :: Number) -> Number:
    if i >= CLOSEST-T-STEPS:
      best-t
    else:
      t  = (i / CLOSEST-T-STEPS) * 2 * PI
      dx = track-cx(trk, t) - px
      dy = track-cy(trk, t) - py
      d2 = (dx * dx) + (dy * dy)
      if d2 < best-d2:
        search(i + 1, t, d2)
      else:
        search(i + 1, best-t, best-d2)
      end
    end
  end
  search(0, 0, 1.0e10)
end
fun closest-t-near(trk :: TrackParams, px :: Number, py :: Number,
                   hint-i :: Number) -> Number:
  fun search(k :: Number, best-i :: Number, best-d2 :: Number) -> Number:
    if k > (2 * CLOSEST-T-WINDOW):
      best-i
    else:
      raw-i = (hint-i + k) - CLOSEST-T-WINDOW
      i =
        if raw-i < 0:                    raw-i + CLOSEST-T-STEPS
        else if raw-i >= CLOSEST-T-STEPS: raw-i - CLOSEST-T-STEPS
        else:                            raw-i
        end
      t  = (i / CLOSEST-T-STEPS) * 2 * PI
      dx = track-cx(trk, t) - px
      dy = track-cy(trk, t) - py
      d2 = (dx * dx) + (dy * dy)
      if d2 < best-d2:
        search(k + 1, i, d2)
      else:
        search(k + 1, best-i, best-d2)
      end
    end
  end
  search(0, hint-i, 1.0e10)
end
# ============================================================
# SENSORS
# ============================================================
fun offset-at-t(trk :: TrackParams, px :: Number, py :: Number,
                t :: Number) -> Number:
  h = track-heading(trk, t)
  ((py - track-cy(trk, t)) * num-cos(h)) - ((px - track-cx(trk, t)) * num-sin(h))
end
fun sharpness-at-t(trk :: TrackParams, t :: Number) -> Number:
  wrap-angle(track-heading(trk, t + LOOKAHEAD) - track-heading(trk, t)) / LOOKAHEAD
end
fun heading-error-at-t(trk :: TrackParams, t :: Number,
                       car-h :: Number) -> Number:
  wrap-angle(car-h - track-heading(trk, t)) * (180 / PI)
end
fun compute-offset(trk :: TrackParams, px :: Number, py :: Number) -> Number:
  offset-at-t(trk, px, py, closest-t(trk, px, py))
end
fun compute-sharpness(trk :: TrackParams, px :: Number, py :: Number) -> Number:
  sharpness-at-t(trk, closest-t(trk, px, py))
end
# ============================================================
# ROAD IMAGE
# ============================================================
GRASS = rectangle(WIDTH, HEIGHT, "solid", "darkgreen")
fun stamp-road(trk :: TrackParams, t :: Number, scene):
  if t >= (2 * PI):
    scene
  else:
    asphalt = circle(ROAD-HALF-WIDTH, "solid", "gray")
    stamp-road(trk, t + 0.02,
      place-image(asphalt, track-cx(trk, t), track-cy(trk, t), scene))
  end
end
fun stamp-stripe(trk :: TrackParams, t :: Number, scene):
  if t >= (2 * PI):
    scene
  else:
    dot = circle(2, "solid", "yellow")
    stamp-stripe(trk, t + 0.06,
      place-image(dot, track-cx(trk, t), track-cy(trk, t), scene))
  end
end
fun make-road-image(trk :: TrackParams):
  stamp-stripe(trk, 0, stamp-road(trk, 0, GRASS))
end
# ============================================================
# HUD
# ============================================================
HUD-LABELS = above-list(
  [list:
    text("speed:           ", 13, "white"),
    square(TEXT-SPACING, "solid", "transparent"),
    text("curve-sharpness: ", 13, "white"),
    square(TEXT-SPACING, "solid", "transparent"),
    text("offset:          ", 13, "white"),
    square(TEXT-SPACING, "solid", "transparent"),
    text("heading-error:   ", 13, "white"),
    square(TEXT-SPACING, "solid", "transparent"),
    text("steering-angle:  ", 13, "yellow")])
fun fmt(v :: Number) -> String:
  num-to-string-digits(v, 6)
end
# ============================================================
# BANNER
# A yellow rectangle showing the current laps-left number, drawn
# at the start of the track (parameter t=0).  The same banner is
# rendered in both views — birds-eye places it at world coords;
# POV projects it through the same pinhole-camera math the road
# uses, so it shrinks with distance.
# ============================================================
fun make-banner(n :: Number):
  bg     = rectangle(80, 30, "solid", "yellow")
  number = text(num-to-string(n), 24, "black")
  overlay(number, bg)
end
fun make-banner-sized(n :: Number, w :: Number, h :: Number):
  text-size = num-min(num-max(8, num-floor(h * 0.6)), 255)
  bg        = rectangle(w, h, "solid", "yellow")
  number    = text(num-to-string(n), text-size, "black")
  overlay(number, bg)
end
# Place the banner at the track's start point, rotated so its long
# axis spans the road perpendicular to the track tangent.
fun add-banner-birds-eye(scene, trk :: TrackParams,
                         laps-left :: Number):
  bnr     = make-banner(laps-left)
  th-deg  = track-heading(trk, 0) * (180 / PI)
  rotated = rotate(90 - th-deg, bnr)
  place-image(rotated, track-cx(trk, 0), track-cy(trk, 0), scene)
end
# Project the start-line position into screen space and place a
# perspective-scaled banner hovering above the projected road.
fun add-banner-pov(scene, s, trk :: TrackParams,
                   laps-left :: Number):
  fx = num-cos(s.heading)
  fy = num-sin(s.heading)
  bx = track-cx(trk, 0)
  by_ = track-cy(trk, 0)
  vx = bx - s.x
  vy = by_ - s.y
  d-f = (vx * fx) + (vy * fy)
  if d-f < POV-NEAR-D:
    scene
  else:
    d-r       = (vy * fx) - (vx * fy)
    bnr-scale = POV-FOCAL / d-f
    sx        = (WIDTH / 2) + (d-r * bnr-scale)
    bnr-h     = num-max(14, num-floor(35 * bnr-scale))
    bnr-w     = num-max(50, num-floor((3 * ROAD-HALF-WIDTH) * bnr-scale))
    sy-road   = POV-HORIZON-Y + (POV-CAM-HEIGHT * bnr-scale)
    sy-banner = sy-road - (60 * bnr-scale)
    if (bnr-w > (3 * WIDTH)) or (sy-banner < (0 - bnr-h)):
      scene
    else:
      bnr = make-banner-sized(laps-left, bnr-w, bnr-h)
      place-image(bnr, sx, sy-banner, scene)
    end
  end
end
# ============================================================
# CAR STATE
# ============================================================
data CarState:
  | car(
      x                 :: Number,
      y                 :: Number,
      heading           :: Number,
      alive             :: Boolean,
      speed-val         :: Number,
      sharpness-val     :: Number,
      offset-val        :: Number,
      heading-error-val :: Number,
      steer-val         :: Number,
      key-left          :: Boolean,
      key-right         :: Boolean,
      t-prev            :: Number)
end
# ============================================================
# GAME STATE
# Wraps a CarState with the world it lives in: the current track,
# its precomputed road image, and how many laps remain on this
# track before regeneration.
# ============================================================
data Game:
  | game(
      car       :: CarState,
      trk       :: TrackParams,
      road-img,
      laps-left :: Number)
end
fun fresh-game() -> Game:
  trk      = random-track()
  road-img = make-road-image(trk)
  c = car(track-cx(trk, 0), track-cy(trk, 0), track-heading(trk, 0),
          true, CAR-SPEED, 0, 0, 0, 0,
          false, false, 0)
  game(c, trk, road-img, LAPS-PER-TRACK)
end
# ============================================================
# SHARED REACTOR HELPERS
# ============================================================
fun car-done(s :: CarState) -> Boolean:
  not(s.alive)
end
fun game-done(g :: Game) -> Boolean:
  not(g.car.alive)
end
# Detect a forward crossing of the start line.  As the car loops,
# `t-prev` (the closest-sample index) increases monotonically and
# wraps from CLOSEST-T-STEPS-1 back to ~0.  A wrap is the only way
# the previous index can be larger than the new one by half the
# loop or more, so this is a clean detector.
fun crossed-start(old-t :: Number, new-t :: Number) -> Boolean:
  (old-t > new-t) and ((old-t - new-t) > (CLOSEST-T-STEPS / 2))
end
fun snap-back(trk :: TrackParams, t-i :: Number, s :: CarState,
              sharpness :: Number, offset :: Number) -> CarState:
  t           = (t-i / CLOSEST-T-STEPS) * 2 * PI
  cx          = track-cx(trk, t)
  cy          = track-cy(trk, t)
  h           = track-heading(trk, t)
  signed-snap = if offset >= 0: ROAD-HALF-WIDTH * 0.6
                else:           0 - (ROAD-HALF-WIDTH * 0.6)
                end
  new-x       = cx - (signed-snap * num-sin(h))
  new-y       = cy + (signed-snap * num-cos(h))
  car(new-x, new-y, h, true,
    s.speed-val, sharpness, signed-snap, 0, s.steer-val,
    s.key-left, s.key-right, t-i)
end
# Per-tick CarState update.  Identical to the previous version —
# game-step calls this and then handles lap-counting and track-
# regeneration on top.
fun make-tick(trk :: TrackParams, get-steering, survival :: Boolean):
  lam(s :: CarState) -> CarState:
    if not(s.alive):
      s
    else:
      t-i         = closest-t-near(trk, s.x, s.y, s.t-prev)
      t           = (t-i / CLOSEST-T-STEPS) * 2 * PI
      offset      = offset-at-t(trk, s.x, s.y, t)
      sharpness   = sharpness-at-t(trk, t)
      heading-err = heading-error-at-t(trk, t, s.heading)
      if num-abs(offset) >= ROAD-HALF-WIDTH:
        if survival:
          snap-back(trk, t-i, s, sharpness, offset)
        else:
          car(s.x, s.y, s.heading, false,
            s.speed-val, sharpness, offset, heading-err, s.steer-val,
            s.key-left, s.key-right, t-i)
        end
      else:
        steering-deg = get-steering(s, sharpness, offset, heading-err)
        new-speed =
          if num-abs(steering-deg) < STEER-DEAD-BAND:
            num-min(s.speed-val + SPEED-STEP, MAX-SPEED)
          else:
            num-max(s.speed-val - SPEED-STEP, MIN-SPEED)
          end
        delta-h      = (steering-deg * (PI / 180)) * STEERING-FACTOR
        new-h        = s.heading + delta-h
        new-x        = s.x + (new-speed * num-cos(new-h))
        new-y        = s.y + (new-speed * num-sin(new-h))
        car(new-x, new-y, new-h, true,
          new-speed, sharpness, offset, heading-err, steering-deg,
          s.key-left, s.key-right, t-i)
      end
    end
  end
end
# Per-tick Game update.  Runs the underlying car-state update,
# then:
#   - if the car just crossed the start line, decrement laps-left;
#   - if laps-left would drop to 0 (or below), regenerate the
#     track, place the car at the new start, and reset the counter.
# The student's `key-left` / `key-right` flags carry across the
# regeneration so they don't have to release-and-re-press keys.
fun game-step(g :: Game, get-steering, survival :: Boolean) -> Game:
  if not(g.car.alive):
    g
  else:
    new-car = make-tick(g.trk, get-steering, survival)(g.car)
    if new-car.alive and crossed-start(g.car.t-prev, new-car.t-prev):
      new-laps = g.laps-left - 1
      if new-laps <= 0:
        new-trk      = random-track()
        new-road-img = make-road-image(new-trk)
        fresh-car = car(
          track-cx(new-trk, 0), track-cy(new-trk, 0), track-heading(new-trk, 0),
          true, CAR-SPEED, 0, 0, 0, 0,
          new-car.key-left, new-car.key-right, 0)
        game(fresh-car, new-trk, new-road-img, LAPS-PER-TRACK)
      else:
        game(new-car, g.trk, g.road-img, new-laps)
      end
    else:
      game(new-car, g.trk, g.road-img, g.laps-left)
    end
  end
end
fun ramp-steering(s :: CarState, sharp :: Number, off :: Number,
                  he :: Number) -> Number:
  # When a key is held the wheel ramps toward ±MAX-STEER as before.
  # When no key is held, instead of just centring the wheel, target
  # a corrective angle: feed-forward on curvature plus pull-back on
  # offset and heading-error.  Net effect: the car gently rights
  # itself when the student lets go, but holding a key still
  # overrides everything.
  target =
    ask:
      | s.key-left  and not(s.key-right) then: 0 - MAX-STEER
      | s.key-right and not(s.key-left)  then: MAX-STEER
      | otherwise:
          (sharp * ASSIST-K-SHARP)
            - (off * ASSIST-K-OFFSET)
            - (he  * ASSIST-K-HEADING)
    end
  approach(s.steer-val, target, STEER-RATE)
end
# ============================================================
# DRAW
# ============================================================
fun draw-car(s :: CarState, alive-color, crashed-color, hud-top, crash-msg, road-img):
  body =
    if s.alive:
      overlay(rectangle(CAR-LENGTH * 0.4, CAR-WIDTH, "solid", "black"),
        rectangle(CAR-LENGTH,        CAR-WIDTH, "solid", alive-color))
    else:
      rectangle(CAR-LENGTH, CAR-WIDTH, "solid", crashed-color)
    end
  rotated = rotate(0 - (s.heading * (180 / PI)), body)
  scene   = place-image(rotated, s.x, s.y, road-img)
  values = above-list(
    [list:
      text(fmt(s.speed-val), 13, "white"),
      square(TEXT-SPACING, "solid", "transparent"),
      text(fmt(s.sharpness-val), 13, "white"),
      square(TEXT-SPACING, "solid", "transparent"),
      text(fmt(s.offset-val), 13, "white"),
      square(TEXT-SPACING, "solid", "transparent"),
      text(fmt(s.heading-error-val), 13, "white"),
      square(TEXT-SPACING, "solid", "transparent"),
      text(fmt(s.steer-val),  13, "yellow")])
  sensor-lines = beside(HUD-LABELS, values)
  hud    = above(hud-top, sensor-lines)
  scene2 = place-image(hud, 104, 8 + (image-height(hud) / 2), scene)
  if s.alive:
    scene2
  else:
    place-image(text(crash-msg, 28, "yellow"), WIDTH / 2, HEIGHT / 2, scene2)
  end
end
POV-BACKGROUND = above(
  rectangle(WIDTH, POV-HORIZON-Y,             "solid", "skyblue"),
  rectangle(WIDTH, HEIGHT - POV-HORIZON-Y,    "solid", "darkgreen"))
fun draw-pov(s :: CarState, trk :: TrackParams, hud-top, crash-msg):
  current-t = (s.t-prev / CLOSEST-T-STEPS) * 2 * PI
  fx        = num-cos(s.heading)
  fy        = num-sin(s.heading)
  fun draw-segs(i :: Number, scene):
    if i < 0:
      scene
    else:
      t-sample = current-t + (i * POV-STEP)
      cx       = track-cx(trk, t-sample)
      cy       = track-cy(trk, t-sample)
      vx       = cx - s.x
      vy       = cy - s.y
      d-f      = (vx * fx) + (vy * fy)
      if d-f < POV-NEAR-D:
        draw-segs(i - 1, scene)
      else:
        d-r   = (vy * fx) - (vx * fy)
        shadow scale = POV-FOCAL / d-f
        sx    = (WIDTH / 2)   + (d-r * scale)
        sy    = POV-HORIZON-Y + (POV-CAM-HEIGHT * scale)
        width = (2 * ROAD-HALF-WIDTH) * scale
        if (sy > HEIGHT) or (width > (2 * WIDTH)):
          draw-segs(i - 1, scene)
        else:
          band-color =
            if num-modulo(i, 2) == 0: "gray" else: "dimgray" end
          asphalt = rectangle(width, 7, "solid", band-color)
          scene-1 = place-image(asphalt, sx, sy, scene)
          scene-2 =
            if num-modulo(i, 2) == 0:
              place-image(circle(2, "solid", "yellow"), sx, sy, scene-1)
            else:
              scene-1
            end
          draw-segs(i - 1, scene-2)
        end
      end
    end
  end
  scene = draw-segs(POV-LOOKAHEAD, POV-BACKGROUND)
  values = above-list(
    [list:
      text(fmt(s.speed-val),         13, "white"),
      square(TEXT-SPACING, "solid", "transparent"),
      text(fmt(s.sharpness-val),     13, "white"),
      square(TEXT-SPACING, "solid", "transparent"),
      text(fmt(s.offset-val),        13, "white"),
      square(TEXT-SPACING, "solid", "transparent"),
      text(fmt(s.heading-error-val), 13, "white"),
      square(TEXT-SPACING, "solid", "transparent"),
      text(fmt(s.steer-val),         13, "yellow")])
  sensor-lines = beside(HUD-LABELS, values)
  hud    = above(hud-top, sensor-lines)
  scene2 = place-image(hud, 104, 8 + (image-height(hud) / 2), scene)
  if s.alive:
    scene2
  else:
    place-image(text(crash-msg, 28, "yellow"), WIDTH / 2, HEIGHT / 2, scene2)
  end
end
# ============================================================
# REACTOR FACTORY
# `frames-per-second` is your knob for slow machines: recommend
# 20fps on fast machines, and 12fps on slow ones
# ============================================================
fun drive(predictor, frames-per-second):
  initial = fresh-game()
  fun get-steering(s, sharpness, offset, heading-err):
    r = [Tables.raw-row:
      {"speed";           s.speed-val},
      {"curve-sharpness"; sharpness},
      {"offset";          offset},
      {"heading-error";   heading-err}]
    predictor(r)
  end
  fun tick-fn(g): game-step(g, get-steering, false) end
  fun draw-fn(g):
    base = draw-car(g.car, "red", "darkred", empty-image, "CRASHED", g.road-img)
    add-banner-birds-eye(base, g.trk, g.laps-left)
  end
  r = reactor:
    init:             initial,
    on-tick:          tick-fn,
    seconds-per-tick: 1 / frames-per-second,
    to-draw:          draw-fn,
    stop-when:        game-done,
    title:            "ML-driven car"
  end
  r.interact()
end
# ============================================================
# TRAINING REACTOR FACTORIES
# ============================================================
fun handle-train-key(s :: CarState, event) -> CarState:
  is-down = event.action == "keydown"
  is-up   = event.action == "keyup"
  if (event.key == "escape") and is-down:
    car(s.x, s.y, s.heading, false,
      s.speed-val, s.sharpness-val, s.offset-val,
      s.heading-error-val, s.steer-val,
      s.key-left, s.key-right, s.t-prev)
  else:
    new-left =
      ask:
        | (event.key == "left")  and is-down then: true
        | (event.key == "left")  and is-up   then: false
        | otherwise:                              s.key-left
      end
    new-right =
      ask:
        | (event.key == "right") and is-down then: true
        | (event.key == "right") and is-up   then: false
        | otherwise:                              s.key-right
      end
    car(s.x, s.y, s.heading, s.alive,
      s.speed-val, s.sharpness-val, s.offset-val,
      s.heading-error-val, s.steer-val,
      new-left, new-right, s.t-prev)
  end
end
# Lift the CarState handler to operate on the surrounding Game.
fun handle-train-key-game(g :: Game, event) -> Game:
  game(handle-train-key(g.car, event), g.trk, g.road-img, g.laps-left)
end
fun training-hud-top(s :: CarState):
  steer-label = ask:
    | s.steer-val < (0 - 1) then: text("◄  TURNING LEFT",  13, "cyan")
    | s.steer-val > 1       then: text("TURNING RIGHT  ►", 13, "cyan")
    | otherwise:                  text("●  STRAIGHT",      13, "white")
  end
  above-list([list:
      text("TRAINING MODE  ←  →   Esc to save", 13, "lime"),
      square(TEXT-SPACING, "solid", "transparent"),
      steer-label,
      square(TEXT-SPACING, "solid", "transparent")
    ])
end
# Runs a training session and returns the recorded data table.
# `draw-fn` is a (Game -> Image) — each train variant supplies its
# own to pick the rendering style and overlay the banner.
fun run-training(frames-per-second, draw-fn):
  initial = fresh-game()
  fun tick-fn(g): game-step(g, ramp-steering, true) end
  r = reactor:
    init:             initial,
    on-tick:          tick-fn,
    on-raw-key:       handle-train-key-game,
    seconds-per-tick: 1 / frames-per-second,
    to-draw:          draw-fn,
    stop-when:        game-done,
    title:            "Training mode — hold ← or → to steer"
  end
  alive  = r.interact-trace().filter({(row): row["state"].car.alive})
  states = alive.all-rows().map({(row): row["state"].car})
  [Tables.table-from-columns:
    {"id";              alive.column("tick")},
    {"speed";           states.map({(s): s.speed-val         })},
    {"curve-sharpness"; states.map({(s): s.sharpness-val     })},
    {"offset";          states.map({(s): s.offset-val        })},
    {"heading-error";   states.map({(s): s.heading-error-val })},
    {"steering-angle";  states.map({(s): s.steer-val         })}]
end
# Birds-eye training: track viewed from above.
fun train(frames-per-second):
  fun draw-fn(g):
    base = draw-car(g.car, "royalblue", "darkblue",
      training-hud-top(g.car),
      "Training session ended — data saved",
      g.road-img)
    add-banner-birds-eye(base, g.trk, g.laps-left)
  end
  run-training(frames-per-second, draw-fn)
end
# Driver's-view training: road viewed from inside the car.
fun train-pov(frames-per-second):
  fun draw-fn(g):
    base = draw-pov(g.car, g.trk,
      training-hud-top(g.car),
      "Training session ended — data saved")
    add-banner-pov(base, g.car, g.trk, g.laps-left)
  end
  run-training(frames-per-second, draw-fn)
end
# ============================================================
# DATA POST-PROCESSING
# ============================================================
fun moving-average(xs, window):
  n    = xs.length()
  half = num-floor((window - 1) / 2)
  fun avg-at(i):
    lo  = num-max(0, i - half)
    hi  = num-min(n - 1, i + half)
    sub = xs.drop(lo).take((hi - lo) + 1)
    sub.foldl(lam(acc, x): acc + x end, 0) / sub.length()
  end
  Lists.range(0, n).map(avg-at)
end
fun smooth(t):
  [Tables.table-from-columns:
    {"id";              t.column("id")},
    {"speed";           t.column("speed")},
    {"curve-sharpness"; t.column("curve-sharpness")},
    {"offset";          t.column("offset")},
    {"heading-error";   t.column("heading-error")},
    {"steering-angle";  moving-average(t.column("steering-angle"), 5)}]
end
# ============================================================
# Load some really good, pre-trained data
# ============================================================
fun get-awesome-data():
  url = "https://docs.google.com/spreadsheets/d/1G6zAS1QS7OTRLaLMCm3yO_ug45VJJNxAK8_uTyY1sYo/export?format=csv"
  load-table: id, curve-sharpness, speed, offset, heading-error, steering-angle
    source: csv.csv-table-url(url, {
          header-row: true,
          infer-content: true
        })
  end
end
#|
   # ============================================================
   # OPTIONAL stub controller — *not* a learned model. It's a
   # hand-tuned proportional rule that lets you confirm the
   # harness works before you swap in your real trained function.
   # ============================================================
   fun stub-trained(r) -> Number:
     off   = r["offset"]
     sharp = r["curve-sharpness"]
     he    = r["heading-error"]
     # Steer toward the centerline + feed-forward on track curvature
     # + drift-angle correction.  Gains 22 / -3.0 / -2.5 from offline
     # grid search; complete laps with peak deviation ~27 px on a
     # 45 px-wide road across multiple track shapes.
     (sharp * 22) - (off * 3.0) - (he * 2.5)
   end
   # Uncomment to try it out:
   # drive(stub-trained, 0.1)
|#