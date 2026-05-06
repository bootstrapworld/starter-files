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
STEERING-FACTOR = 0.035     # converts model degrees -> rad/tick of yaw
LOOKAHEAD       = 0.08      # parameter step for measuring track curvature
MAX-STEER       = 90        # max |steering angle| (degrees) the wheel can reach
STEER-RATE      = 8         # how fast the wheel ramps toward its target each tick
MAX-SHARPNESS   = 6.0       # max |dθ/dt| allowed at any point on the track

# Speed dynamics — speed creeps up toward MAX-SPEED while the wheel
# is within ±STEER-DEAD-BAND of centre, and creeps back down toward
# MIN-SPEED whenever the wheel is turned more sharply than that.
# This both gives the regression a varying `speed` column to work
# with (a constant column makes the matrix solver singular) and
# matches how a real driver lifts off the throttle in a turn.
CAR-SPEED       = 2.0       # initial speed; varies between MIN-SPEED and MAX-SPEED at runtime
MIN-SPEED       = 2.0
MAX-SPEED       = 3.0
SPEED-STEP      = 0.05      # how much speed changes per tick
STEER-DEAD-BAND = 15        # |steering| < this counts as "near-straight"

# Closest-t search constants
CLOSEST-T-STEPS  = 480      # samples around the loop
CLOSEST-T-WINDOW =  10      # ± window for the per-tick incremental search

# POV (driver's view) rendering constants
POV-HORIZON-Y   = 250       # screen y of the horizon line
POV-FOCAL       = 280       # perspective focal length
POV-CAM-HEIGHT  =  60       # camera height above the road plane
POV-LOOKAHEAD   =  60       # number of road samples to project ahead
POV-STEP        = 0.05      # t-step between samples
POV-NEAR-D      =  15       # don't render samples closer than this (world px)
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
# Move `current` toward `target` by at most `max-step`.  Used by the
# steering-ramp model below.
fun approach(current :: Number, target :: Number, max-step :: Number) -> Number:
  diff = target - current
  if num-abs(diff) <= max-step: target
  else if diff > 0: current + max-step
  else: current - max-step
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
fun offset-at-t(trk :: TrackParams, px :: Number, py :: Number,
                t :: Number) -> Number:
  h = track-heading(trk, t)
  ((py - track-cy(trk, t)) * num-cos(h)) - ((px - track-cx(trk, t)) * num-sin(h))
end
fun sharpness-at-t(trk :: TrackParams, t :: Number) -> Number:
  wrap-angle(track-heading(trk, t + LOOKAHEAD) - track-heading(trk, t)) / LOOKAHEAD
end
# Signed angle (in degrees) between the car's heading and the
# track's tangent at parameter t.  Positive = the car is rotated
# clockwise relative to the road (pointing further "right" than
# the road goes); negative = rotated counter-clockwise.  Without
# this feature the model can't tell "I'm 0px off-centre, pointed
# along the road" apart from "I'm 0px off-centre, pointed
# perpendicular off the road" — both project to the same point
# in (offset, sharpness, speed) space.
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
    text("heading-error:   ", 13, "white"),
    square(TEXT-SPACING, "solid", "transparent"),
    text("steering-angle:  ", 13, "yellow")])
fun fmt(v :: Number) -> String:
  easy-num-repr(v, 6)
end
# ============================================================
# CAR STATE
# `t-prev`                 caches the previous tick's closest-
#                          sample index for the incremental
#                          closest-t search.
# `heading-error-val`      signed angle (deg) between the car's
#                          heading and the track tangent.  Lets
#                          the model learn to recover when it's
#                          pointed the wrong way — without this
#                          feature the car sails perpendicularly
#                          off the road with no corrective signal.
# `key-left` / `key-right` track which arrow keys are currently
#                          held down in training mode.  The wheel's
#                          actual angle (`steer-val`) ramps smoothly
#                          toward its target each tick, so the
#                          recorded steering values span the full
#                          continuous range.
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
# SHARED REACTOR HELPERS
# ============================================================
fun car-done(s :: CarState) -> Boolean:
  not(s.alive)
end
# Snap the car back into the lane when it has gone off the road.
# Used by training mode (survival = true) so that a single misstep
# doesn't erase the whole run.  The car is placed at
# ±0.6 * ROAD-HALF-WIDTH on the side it left, and its heading is
# reset to the track's tangent so the next tick doesn't push it
# straight back off the road.
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
  # heading reset to track tangent ⇒ heading-error = 0
  car(new-x, new-y, h, true,
      s.speed-val, sharpness, signed-snap, 0, s.steer-val,
      s.key-left, s.key-right, t-i)
end
# Returns a tick function whose only variable behaviour is how
# the steering angle is obtained.
# get-steering :: (CarState, sharpness :: Number, offset :: Number) -> Number
#
# Speed update: each tick the speed creeps toward MAX-SPEED when
# the wheel is within STEER-DEAD-BAND of centre, and toward
# MIN-SPEED otherwise.  Same dynamics in drive and train.
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
# Steering rule used by training mode: ramp the wheel toward
# (-MAX-STEER, 0, +MAX-STEER) depending on which keys are held.
# When neither is held, the wheel self-centres back to 0 at the
# same rate.  This is what produces continuous, time-correlated
# steering values in the recorded data.
fun ramp-steering(s :: CarState, _sharp :: Number, _off :: Number,
                  _he :: Number) -> Number:
  target =
    ask:
      | s.key-left  and not(s.key-right) then: 0 - MAX-STEER
      | s.key-right and not(s.key-left)  then: MAX-STEER
      | otherwise:                            0
    end
  approach(s.steer-val, target, STEER-RATE)
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
# Pre-built sky+ground background for the POV view (built once).
POV-BACKGROUND = above(
  rectangle(WIDTH, POV-HORIZON-Y,             "solid", "skyblue"),
  rectangle(WIDTH, HEIGHT - POV-HORIZON-Y,    "solid", "darkgreen"))
# Driver's-view draw pass.  Renders the road as a perspective
# projection of road-centerline samples taken ahead of the car —
# each sample becomes a horizontal slice whose width and screen
# position come from a pinhole-camera formula.  When the road
# curves, the slices march sideways across the screen, which makes
# left vs. right intuitive without a birds-eye reference frame.
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
  trk      = random-track()
  road-img = make-road-image(trk)
  initial  = car(track-cx(trk, 0), track-cy(trk, 0), track-heading(trk, 0),
                 true, CAR-SPEED, 0, 0, 0, 0,
                 false, false, 0)
  fun get-steering(s, sharpness, offset, heading-err):
    r = [Tables.raw-row:
          {"speed";           s.speed-val},
          {"curve-sharpness"; sharpness},
          {"offset";          offset},
          {"heading-error";   heading-err}]
    predictor(r)
  end
  fun draw(s): draw-car(s, "red", "darkred", empty-image, "CRASHED", road-img) end
  r = reactor:
    init:             initial,
    on-tick:          make-tick(trk, get-steering, false),
    seconds-per-tick: 1 / frames-per-second,
    to-draw:          draw,
    stop-when:        car-done,
    title:            "ML-driven car"
  end
  r.interact()
end
# ============================================================
# TRAINING REACTOR FACTORIES
#
# `train` (birds-eye) and `train-pov` (driver's view) share
# everything except their draw function.  Both: arrow keys flip
# `key-left` / `key-right`; every tick `ramp-steering` reads those
# flags and nudges the wheel toward (-MAX-STEER, +MAX-STEER, or 0).
# The continuous-valued `steer-val` that comes out is what gets
# logged into `steering-angle` for the regression to learn from.
# Esc ends the session and `interact-trace` returns the table.
# ============================================================
# Keyboard handler shared by both training variants.
fun handle-train-key(s :: CarState, event) -> CarState:
  is-down = event.action == "keydown"
  is-up   = event.action == "keyup"
  # Esc ends the session.  In survival mode the car never crashes
  # on its own, so without an explicit "stop" key the student
  # would have to close the reactor window manually.
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
# Builds the "TRAINING MODE" banner with the live LEFT/RIGHT/
# STRAIGHT indicator.  Result is passed as the `hud-top` argument
# to whichever draw function the caller picked.
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
# `make-draw` is a builder
#     (TrackParams -> (CarState -> Image))
# so each train variant can precompute track-dependent state
# (e.g. the birds-eye road image) exactly once before the reactor
# starts, instead of every frame.
fun run-training(frames-per-second, make-draw):
  trk     = random-track()
  initial = car(track-cx(trk, 0), track-cy(trk, 0), track-heading(trk, 0),
                true, CAR-SPEED, 0, 0, 0, 0,
                false, false, 0)
  draw    = make-draw(trk)
  r = reactor:
    init:             initial,
    on-tick:          make-tick(trk, ramp-steering, true),
    on-raw-key:       handle-train-key,
    seconds-per-tick: 1 / frames-per-second,
    to-draw:          draw,
    stop-when:        car-done,
    title:            "Training mode — hold ← or → to steer"
  end
  alive  = r.interact-trace().filter({(row): row["state"].alive})
  states = alive.all-rows().map({(row): row["state"]})
  [Tables.table-from-columns:
    {"id";              alive.column("tick")},
    {"speed";           states.map({(s): s.speed-val         })},
    {"curve-sharpness"; states.map({(s): s.sharpness-val     })},
    {"offset";          states.map({(s): s.offset-val        })},
    {"heading-error";   states.map({(s): s.heading-error-val })},
    {"steering-angle";  states.map({(s): s.steer-val         })}]
end
# Birds-eye training: track viewed from above.  Better for
# spatial intuition, but harder for kids to react to curves.
fun train(frames-per-second):
  run-training(frames-per-second,
    lam(trk):
      road-img = make-road-image(trk)
      lam(s :: CarState):
        draw-car(s, "royalblue", "darkblue",
          training-hud-top(s),
          "Training session ended — data saved",
          road-img)
      end
    end)
end
# Driver's-view training: road viewed from inside the car.
# Curves visibly bend left/right ahead of the driver, which makes
# the right reaction obvious without spatial reasoning.
fun train-pov(frames-per-second):
  run-training(frames-per-second,
    lam(trk):
      lam(s :: CarState):
        draw-pov(s, trk,
          training-hud-top(s),
          "Training session ended — data saved")
      end
    end)
end
# ============================================================
# DATA POST-PROCESSING
# ============================================================
# Returns a new list the same length as `xs`, where each element
# is the mean of up to `window` elements centred on it.  At the
# ends of the list the window is clipped (rather than dropped),
# so the first element averages the first `(window+1)/2` values,
# the second averages `(window+1)/2 + 1` values, etc.  Length is
# preserved.
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
# Smooths the `steering-angle` column of a training-data table
# with a 5-sample centred moving average; the other columns pass
# through unchanged.  Most of the flutter and overshoot in
# human-collected data lives in `steering-angle`, and a small
# centred average filters it out without changing the overall
# shape of the signal.  Use it before fitting to compare:
#
#     # raw
#     model-a = mr-fun(my-data,
#                      [list: "speed", "curve-sharpness", "offset"],
#                      "steering-angle")
#     # smoothed
#     model-b = mr-fun(smooth(my-data),
#                      [list: "speed", "curve-sharpness", "offset"],
#                      "steering-angle")
fun smooth(t):
  [Tables.table-from-columns:
    {"id";              t.column("id")},
    {"speed";           t.column("speed")},
    {"curve-sharpness"; t.column("curve-sharpness")},
    {"offset";          t.column("offset")},
    {"heading-error";   t.column("heading-error")},
    {"steering-angle";  moving-average(t.column("steering-angle"), 5)}]
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