use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")
################################################################
# Bootstrap Self-Driving Car Library, as of Fall 2026

provide *

# re-export every symbol from Core
import url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr") as Core
import csv as csv
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
# (in that order, matching your training table) and the return
# value is the steering-wheel angle in degrees (positive = right).
#
# Usage:
#     my-reactor = make-reactor(my-trained-function)
#     interact(my-reactor)
#
# A tiny hand-coded "stub" controller is included at the bottom
# so you can sanity-check the harness before plugging in a real
# trained model.
# ============================================================

# ---- Display ---------------------------------------------------
WIDTH           = 800
HEIGHT          = 600
ROAD-HALF-WIDTH = 45        # pixels from centerline to road edge
CAR-LENGTH      = 26
CAR-WIDTH       = 14

# ---- Driving model --------------------------------------------
CAR-SPEED       = 3.5       # px / tick — also fed as the `speed` input
STEERING-FACTOR = 0.035     # converts model degrees -> rad/tick of yaw
LOOKAHEAD       = 0.08      # parameter step for measuring track curvature
MANUAL-STEER    = 90        # degrees applied while a direction key is held

# ============================================================
# TRACK CENTERLINE
# A closed parametric curve. Mixing sinusoids of different
# frequencies gives a track with both gentle and sharp turns,
# in both directions — much better practice than a circle.
# ============================================================

fun track-cx(t :: Number) -> Number:
  (WIDTH / 2) + (250 * num-cos(t)) + (55 * num-cos(3 * t))
end

fun track-cy(t :: Number) -> Number:
  (HEIGHT / 2) + (180 * num-sin(t)) + (45 * num-sin(2 * t))
end

# Tangent components — derivatives of the centerline w.r.t. t.
fun track-dx(t :: Number) -> Number:
  (-250 * num-sin(t)) + (-165 * num-sin(3 * t))
end

fun track-dy(t :: Number) -> Number:
  (180 * num-cos(t)) + (90 * num-cos(2 * t))
end

fun track-heading(t :: Number) -> Number:
  num-atan2(track-dy(t), track-dx(t))
end

# Normalise an angle delta into [-PI, PI].
fun wrap-angle(a :: Number) -> Number:
  ask:
    | a > PI       then: a - (2 * PI)
    | a < (0 - PI) then: a + (2 * PI)
    | otherwise:   a
  end
end

# Find the parameter value on the centerline closest to (px, py).
# Brute-force sample of the loop — plenty fast for a 30 fps animation.
fun closest-t(px :: Number, py :: Number) -> Number:
  STEPS = 480
  fun search(i :: Number, best-t :: Number, best-d2 :: Number) -> Number:
    if i >= STEPS:
      best-t
    else:
      t  = (i / STEPS) * 2 * PI
      dx = track-cx(t) - px
      dy = track-cy(t) - py
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

# ============================================================
# SENSORS — what the car "sees"
# ============================================================

# Signed offset: + means car is to the RIGHT of the centerline (in
# the driver's frame of reference), - means to the LEFT. So a
# well-trained controller will steer to the LEFT (negative degrees)
# when offset is positive, and vice versa.
fun compute-offset(px :: Number, py :: Number) -> Number:
  t = closest-t(px, py)
  h = track-heading(t)
  ((py - track-cy(t)) * num-cos(h)) - ((px - track-cx(t)) * num-sin(h))
end

# Curve sharpness: how fast the track's heading is changing just ahead.
# + means the track is bending left, - means right.
fun compute-sharpness(px :: Number, py :: Number) -> Number:
  t = closest-t(px, py)
  wrap-angle(track-heading(t + LOOKAHEAD) - track-heading(t)) / LOOKAHEAD
end

# ============================================================
# STATIC ROAD IMAGE
# Drawn once at module load by stamping circles along the
# centerline; the car is overlaid on top each frame.
# ============================================================

fun stamp-road(t :: Number, scene):
  if t >= (2 * PI):
    scene
  else:
    asphalt = circle(ROAD-HALF-WIDTH, "solid", "gray")
    stamp-road(t + 0.012, place-image(asphalt, track-cx(t), track-cy(t), scene))
  end
end

fun stamp-stripe(t :: Number, scene):
  if t >= (2 * PI):
    scene
  else:
    dot = circle(2, "solid", "yellow")
    stamp-stripe(t + 0.045, place-image(dot, track-cx(t), track-cy(t), scene))
  end
end

GRASS      = rectangle(WIDTH, HEIGHT, "solid", "darkgreen")
ROAD-IMAGE = stamp-stripe(0, stamp-road(0, GRASS))

# ============================================================
# CAR STATE
# ============================================================

data CarState:
  | car(
      x :: Number, 
      y :: Number, 
      heading :: Number, 
      alive :: Boolean,
      speed-val :: Number, 
      sharpness-val :: Number, 
      offset-val :: Number, 
      steer-val :: Number)
end

INITIAL-STATE = car(track-cx(0), track-cy(0), track-heading(0), true, CAR-SPEED, 0, 0, 0)
# ============================================================
# SHARED REACTOR HELPERS
# ============================================================

fun car-done(s :: CarState) -> Boolean:
  not(s.alive)
end

# Returns a tick function whose only variable behaviour is how
# the steering angle is obtained.
# get-steering :: (CarState, sharpness :: Number, offset :: Number) -> Number
fun make-tick(get-steering):
  lam(s :: CarState) -> CarState:
    if not(s.alive):
      s
    else:
      offset       = compute-offset(s.x, s.y)
      sharpness    = compute-sharpness(s.x, s.y)
      steering-deg = get-steering(s, sharpness, offset)
      delta-h      = (steering-deg * (PI / 180)) * STEERING-FACTOR
      new-h        = s.heading + delta-h
      new-x        = s.x + (CAR-SPEED * num-cos(new-h))
      new-y        = s.y + (CAR-SPEED * num-sin(new-h))
      still-alive  = num-abs(compute-offset(new-x, new-y)) < ROAD-HALF-WIDTH
      car(new-x, new-y, new-h, still-alive, CAR-SPEED, sharpness, offset, steering-deg)
    end
  end
end

# Full draw pass.  hud-top is an Image placed above the four
# sensor lines — pass empty-image when nothing extra is needed.
fun draw-car(s :: CarState, alive-color, crashed-color, hud-top, crash-msg):
  body = if s.alive:
    overlay(rectangle(CAR-LENGTH * 0.4, CAR-WIDTH, "solid", "black"),
            rectangle(CAR-LENGTH,        CAR-WIDTH, "solid", alive-color))
  else:
    rectangle(CAR-LENGTH, CAR-WIDTH, "solid", crashed-color)
  end
  rotated = rotate(0 - (s.heading * (180 / PI)), body)
  scene   = place-image(rotated, s.x, s.y, ROAD-IMAGE)
  fmt     = lam(v): easy-num-repr(v, 6) end
  sensor-lines = above(
    text("speed:           " + fmt(s.speed-val),       13, "white"),
    above(
      text("curve-sharpness: " + fmt(s.sharpness-val), 13, "white"),
      above(
        text("offset:          " + fmt(s.offset-val),  13, "white"),
        text("steering-angle:  " + fmt(s.steer-val),   13, "yellow")
      )
    )
  )
  hud    = above(hud-top, sensor-lines)
  # place-image centres on (x,y); put the top edge 8px from screen top.
  scene2 = place-image(hud, 104, 8 + (image-height(hud) / 2), scene)
  if s.alive:
    scene2
  else:
    place-image(text(crash-msg, 28, "yellow"), WIDTH / 2, HEIGHT / 2, scene2)
  end
end

# ============================================================
# REACTOR FACTORY
# ============================================================
fun drive(predictor):
  fun get-steering(s, sharpness, offset):
    input-tab = table: speed, curve-sharpness, offset
      row: CAR-SPEED, sharpness, offset
    end
    predictor(input-tab.row-n(0))
  end
  fun draw(s): draw-car(s, "red", "darkred", empty-image, "CRASHED") end
  reactor:
    init:             INITIAL-STATE,
    on-tick:          make-tick(get-steering),
    seconds-per-tick: 0.033,
    to-draw:          draw,
    stop-when:        car-done,
    title:            "ML-driven car"
  end
end


# ============================================================
# TRAINING REACTOR FACTORY
# ============================================================
fun train():
  fun handle-raw-key(s :: CarState, event) -> CarState:
    left  = event.key == "left"
    right = event.key == "right"
    ask:
      | (event.action == "keydown") and left  then:
        car(s.x, s.y, s.heading, s.alive,
            s.speed-val, s.sharpness-val, s.offset-val, 0 - MANUAL-STEER)
      | (event.action == "keydown") and right then:
        car(s.x, s.y, s.heading, s.alive,
            s.speed-val, s.sharpness-val, s.offset-val, MANUAL-STEER)
      | (event.action == "keyup") and (left or right) then:
        car(s.x, s.y, s.heading, s.alive,
            s.speed-val, s.sharpness-val, s.offset-val, 0)
      | otherwise: s
    end
  end
  fun draw(s):
    steer-label = ask:
      | s.steer-val < 0 then: text("◄  STEERING LEFT",  13, "cyan")
      | s.steer-val > 0 then: text("STEERING RIGHT  ►", 13, "cyan")
      | otherwise:             text("●  STRAIGHT",       13, "white")
    end
    draw-car(s, "royalblue", "darkblue",
      above(text("TRAINING MODE  ←  →", 13, "lime"), steer-label),
      "CRASHED — close to save data")
  end
  r = reactor:
    init:             INITIAL-STATE,
    on-tick:          make-tick(lam(s, _sh, _off): s.steer-val end),
    on-raw-key:       handle-raw-key,
    seconds-per-tick: 0.033,
    to-draw:          draw,
    stop-when:        car-done,
    title:            "Training mode — hold ← or → to steer"
  end
  
  states = r.interact-trace()
  alive = L.filter({(s): s.alive }, states)
  [T.table-from-columns: 
    {"speed";           alive.map({(s): s.speed-val     })}, 
    {"curve-sharpness"; alive.map({(s): s.sharpness-val })},
    {"offset";          alive.map({(s): s.offset-val    })},
    {"steering-angle";  alive.map({(s): s.steer-val     })}]  
end


# ============================================================
# OPTIONAL stub controller — *not* a learned model. It's a
# hand-tuned proportional rule that lets you confirm the
# harness works before you swap in your real trained function.
# Comment it out (and the example reactor below it) once you
# have your own model.
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
#
example-reactor = drive(stub-trained)
example-reactor.interact()




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