use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")
################################################################
# Bootstrap Self-Driving Car Library, as of Fall 2026
provide *
# re-export every symbol from Core
import url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr") as Core
import csv as csv
import tables as Tables
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
# where the row has columns [speed, curve-sharpness, offset]
# (in that order) and the return value is the steering-wheel
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
CAR-SPEED       = 3.5       # px / tick — also fed as the `speed` input
STEERING-FACTOR = 0.035     # converts model degrees -> rad/tick of yaw
LOOKAHEAD       = 0.08      # parameter step for measuring track curvature
MANUAL-STEER    = 90        # degrees applied while a direction key is held
MAX-SHARPNESS   = 6.0       # max |dθ/dt| allowed at any point on the track

# Closest-t search constants
CLOSEST-T-STEPS  = 480      # samples around the loop
CLOSEST-T-WINDOW =  10      # ± window for the per-tick incremental search

# ============================================================
# TRACK PARAMETERS
# Randomised once per reactor call so every run uses a fresh track.
# ============================================================
data TrackParams:
  | track-params(
      a1 :: Number, a2 :: Number,   # x amplitudes (harmonics 1, 3)
      b1 :: Number, b2 :: Number,   # y amplitudes (harmonics 1, 2)
      ph :: Number,                 # phase of both fundamentals (0-2π)
      qx :: Number,                 # extra phase of x third-harmonic (0-2π)
      qy :: Number)                 # extra phase of y second-harmonic (0-2π)
end

# Returns true when no point on the track has |sharpness| > MAX-SHARPNESS.
# Samples 120 evenly-spaced parameter values — fine enough to catch
# any tight bend without being slow.
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

# Produces a fresh randomised track each call, retrying until the
# sharpness constraint is satisfied.
fun random-track() -> TrackParams:
  trk = track-params(
    150 + num-random(101),  # a1: main x-amplitude       (150-250)
     20 + num-random(51),   # a2: x third-harmonic        (20-70)
    100 + num-random(81),   # b1: main y-amplitude       (100-180)
     15 + num-random(46),   # b2: y second-harmonic       (15-60)
    num-random(629) / 100,  # ph: fundamental phase       (0-2π)
    num-random(629) / 100,  # qx: x sub-harmonic phase    (0-2π)
    num-random(629) / 100)  # qy: y sub-harmonic phase    (0-2π)
  if check-track(trk): trk
  else: random-track()
  end
end

# ============================================================
# TRACK CENTERLINE
# A closed parametric curve. Mixing sinusoids of different
# frequencies gives a track with both gentle and sharp turns,
# in both directions — much better practice than a circle.
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

# Normalise an angle delta into [-PI, PI].
fun wrap-angle(a :: Number) -> Number:
  ask:
    | a > PI       then: a - (2 * PI)
    | a < (0 - PI) then: a + (2 * PI)
    | otherwise:   a
  end
end

# ============================================================
# CLOSEST-T SEARCH
#
# closest-t          — full 480-sample brute-force (kept available
#                      for general use; not on the per-tick path).
# closest-t-near     — incremental ±WINDOW search starting from a
#                      hint index.  The car only travels ~3.5 px
#                      per tick (less than 2 sample-spacings on a
#                      ~1200 px loop), so a small window can never
#                      miss the true closest sample.  This is the
#                      version called every tick.
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

# Incremental search.  Returns the *sample index* (0..CLOSEST-T-STEPS-1)
# of the closest centerline point.  Convert to a t-value with
# (i / CLOSEST-T-STEPS) * 2 * PI when needed.
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
# SENSORS — what the car "sees"
# ============================================================
# Variants that take a *precomputed* t.  These are what the tick
# function calls; sharing one closest-t across the offset and
# sharpness reads avoids doing the same expensive search twice.

# Signed offset: + means car is to the RIGHT of the centerline (in
# the driver's frame), - means to the LEFT.
fun offset-at-t(trk :: TrackParams, px :: Number, py :: Number,
                t :: Number) -> Number:
  h = track-heading(trk, t)
  ((py - track-cy(trk, t)) * num-cos(h)) - ((px - track-cx(trk, t)) * num-sin(h))
end

# Curve sharpness: how fast the track's heading is changing just ahead.
# + means the track is bending right (driver's view), - means left.
fun sharpness-at-t(trk :: TrackParams, t :: Number) -> Number:
  wrap-angle(track-heading(trk, t + LOOKAHEAD) - track-heading(trk, t)) / LOOKAHEAD
end

# Convenience wrappers for non-tick code (do their own brute-force search).
fun compute-offset(trk :: TrackParams, px :: Number, py :: Number) -> Number:
  offset-at-t(trk, px, py, closest-t(trk, px, py))
end
fun compute-sharpness(trk :: TrackParams, px :: Number, py :: Number) -> Number:
  sharpness-at-t(trk, closest-t(trk, px, py))
end

# ============================================================
# ROAD IMAGE
# Built once per reactor call by stamping circles along the
# centerline; the car is overlaid on top each frame.  The step
# sizes below were thinned (0.012 → 0.02 for asphalt, 0.045 →
# 0.06 for stripes) — visually identical, ~40 % fewer stamps.
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
# HUD — pre-built static labels (reused every frame)
# ============================================================
HUD-LABELS = above-list(
  [list:
    text("speed:           ", 13, "white"),
    square(TEXT-SPACING, "solid", "transparent"),
    text("curve-sharpness: ", 13, "white"),
    square(TEXT-SPACING, "solid", "transparent"),
    text("offset:          ", 13, "white"),
    square(TEXT-SPACING, "solid", "transparent"),
    text("steering-angle:  ", 13, "yellow")])

# Top-level helper, no closure allocation per draw.
fun fmt(v :: Number) -> String:
  easy-num-repr(v, 6)
end

# ============================================================
# CAR STATE
# `t-prev` caches the previous tick's closest-sample index so the
# next tick's closest-t-near search can start from a tight window
# around it instead of re-scanning the whole loop.
# ============================================================
data CarState:
  | car(
      x             :: Number,
      y             :: Number,
      heading       :: Number,
      alive         :: Boolean,
      speed-val     :: Number,
      sharpness-val :: Number,
      offset-val    :: Number,
      steer-val     :: Number,
      t-prev        :: Number)
end

# ============================================================
# SHARED REACTOR HELPERS
# ============================================================
fun car-done(s :: CarState) -> Boolean:
  not(s.alive)
end

# Returns a tick function whose only variable behaviour is how
# the steering angle is obtained.
# get-steering :: (CarState, sharpness :: Number, offset :: Number) -> Number
#
# This used to call closest-t three times per tick (once for
# offset, once for sharpness, once to crash-check the new
# position).  Now it does one incremental closest-t-near call per
# tick and judges liveness from that same offset — so a crash
# registers one frame later than before, which is invisible at
# 30 fps but ~50× cheaper.
fun make-tick(trk :: TrackParams, get-steering):
  lam(s :: CarState) -> CarState:
    if not(s.alive):
      s
    else:
      t-i       = closest-t-near(trk, s.x, s.y, s.t-prev)
      t         = (t-i / CLOSEST-T-STEPS) * 2 * PI
      offset    = offset-at-t(trk, s.x, s.y, t)
      sharpness = sharpness-at-t(trk, t)
      if num-abs(offset) >= ROAD-HALF-WIDTH:
        car(s.x, s.y, s.heading, false,
            CAR-SPEED, sharpness, offset, s.steer-val, t-i)
      else:
        steering-deg = get-steering(s, sharpness, offset)
        delta-h      = (steering-deg * (PI / 180)) * STEERING-FACTOR
        new-h        = s.heading + delta-h
        new-x        = s.x + (CAR-SPEED * num-cos(new-h))
        new-y        = s.y + (CAR-SPEED * num-sin(new-h))
        car(new-x, new-y, new-h, true,
            CAR-SPEED, sharpness, offset, steering-deg, t-i)
      end
    end
  end
end

# Full draw pass.  hud-top is an Image placed above the four
# sensor lines — pass empty-image when nothing extra is needed.
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

# ============================================================
# REACTOR FACTORY
# `seconds-per-frame` is your knob for slow machines: 0.033 ≈ 30
# fps, 0.05 ≈ 20 fps (a third less CPU and barely visible).
# ============================================================
fun drive(predictor, seconds-per-frame):
  trk      = random-track()
  road-img = make-road-image(trk)
  initial  = car(track-cx(trk, 0), track-cy(trk, 0), track-heading(trk, 0),
                 true, CAR-SPEED, 0, 0, 0, 0)
  fun get-steering(s, sharpness, offset):
    r = [Tables.raw-row: {"speed";CAR-SPEED}, {"curve-sharpness";sharpness}, {"offset";offset}]
    predictor(r)
  end
  fun draw(s): draw-car(s, "red", "darkred", empty-image, "CRASHED", road-img) end
  r = reactor:
    init:             initial,
    on-tick:          make-tick(trk, get-steering),
    seconds-per-tick: seconds-per-frame,
    to-draw:          draw,
    stop-when:        car-done,
    title:            "ML-driven car"
  end
  r.interact()
end

# ============================================================
# TRAINING REACTOR FACTORY
# ============================================================
fun train(seconds-per-frame):
  trk      = random-track()
  road-img = make-road-image(trk)
  initial  = car(track-cx(trk, 0), track-cy(trk, 0), track-heading(trk, 0),
                 true, CAR-SPEED, 0, 0, 0, 0)
  fun handle-raw-key(s :: CarState, event) -> CarState:
    left  = event.key == "left"
    right = event.key == "right"
    ask:
      | (event.action == "keydown") and left  then:
        car(s.x, s.y, s.heading, s.alive,
            s.speed-val, s.sharpness-val, s.offset-val, 0 - MANUAL-STEER, s.t-prev)
      | (event.action == "keydown") and right then:
        car(s.x, s.y, s.heading, s.alive,
            s.speed-val, s.sharpness-val, s.offset-val, MANUAL-STEER, s.t-prev)
      | (event.action == "keyup") and (left or right) then:
        car(s.x, s.y, s.heading, s.alive,
            s.speed-val, s.sharpness-val, s.offset-val, 0, s.t-prev)
      | otherwise: s
    end
  end
  fun draw(s):
    steer-label = ask:
      | s.steer-val < 0 then: text("◄  TURNING LEFT",  13, "cyan")
      | s.steer-val > 0 then: text("TURNING RIGHT  ►", 13, "cyan")
      | otherwise:            text("●  STRAIGHT",       13, "white")
    end
    draw-car(s, "royalblue", "darkblue",
      above-list([list:
          text("TRAINING MODE  ←  →", 13, "lime"), 
          square(TEXT-SPACING, "solid", "transparent"),
          steer-label,
          square(TEXT-SPACING, "solid", "transparent")
        ]),
      "CRASHED — close to save data",
      road-img)
  end
  r = reactor:
    init:             initial,
    on-tick:          make-tick(trk, lam(s, _sh, _off): s.steer-val end),
    on-raw-key:       handle-raw-key,
    seconds-per-tick: seconds-per-frame,
    to-draw:          draw,
    stop-when:        car-done,
    title:            "Training mode — hold ← or → to steer"
  end
  states = r.interact-trace()
  alive = states
    .all-rows()
    .map({(row): row["state"]})
    .filter({(row): row.alive})
  [Tables.table-from-columns:
    {"speed";           alive.map({(s): s.speed-val     })},
    {"curve-sharpness"; alive.map({(s): s.sharpness-val })},
    {"offset";          alive.map({(s): s.offset-val    })},
    {"steering-angle";  alive.map({(s): s.steer-val     })}]
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
  # Steer toward the centerline + feed-forward on track curvature.
  # Gains 20 / -2.5 were chosen by an offline grid search and
  # complete laps with peak deviation ~26 px on a 45 px-wide road.
  (sharp * 20) - (off * 2.5)
end
# Uncomment to try it out:
# drive(stub-trained, 0.1)
###########################################################
# for testing purposes
# import the data, perform multiple regression, and
# generate a real, trained model
_training-url = "https://docs.google.com/spreadsheets/d/1G6zAS1QS7OTRLaLMCm3yO_ug45VJJNxAK8_uTyY1sYo/export?format=csv"
_training =
  load-table: id, speed, curve-sharpness, offset, steering-angle
    source: csv.csv-table-url(_training-url, {
      header-row: true,
      infer-content: true
    })
  end
sample-model = mr-fun(_training, [list: "speed", "curve-sharpness", "offset"], "steering-angle")
test = table: speed, curve-sharpness, offset
  row: 3.5, 0, 0
  row: 3.5, 5, 0
  row: 3.5, 0, 10
  row: 3.5,-5, 10
end
|#