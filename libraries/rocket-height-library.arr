use context file("core.arr")

################################################################
# Rocket Height support file, as of Fall 2026

provide *

import lists as L
include from L:
    * hiding(filter, sort, range),
  type *,
  data *
end

import math as Math
provide from Math:
    * hiding(sum),
  type *,
  data *
end

import reactors as R

################################################################
######################### ROCKET HEIGHT ########################

ROCKET = scale(1/2, image-url("http://www.wescheme.org/images/teachpacks2012/rocket.png"))
ROCKET-BG = image-url("http://www.BootstrapWorld.org/clipart/height.png")
UNIVERSE-HEIGHT = 4.35e+26
LOG-UNIVERSE-HEIGHT = 61.33738
UNIVERSE-ZERO-PX = 150
BACKGROUND-PX-ABOVE-GROUND = image-height(ROCKET-BG) - UNIVERSE-ZERO-PX
CENTER = image-width(ROCKET-BG) / 2
ROCKET-HEIGHT = 550
THANKS = text("Thanks to Randall Munroe for the picture of the universe!  https://xkcd.com/482/", 14, "gray")

fun time-text(str):
  text(str, 14, make-color(41, 128, 38, 255))
end

fun height-text(str):
  text(str, 14, make-color(38, 38, 128, 255))
end

fun speed-text(str):
  text(str, 14, "purple")
end

fun tock(w, ke):
  {v :: Number; f :: (Number -> Number)} = w
  ask:
    | ke == " " then: {v + 1; f}
    | v <= 0 then: {0; f}
    | ke == "b" then: {v - 1; f}
    | otherwise: w
  end
end

fun legend(w):

  fun ss(n, str):
    if num-to-rational(n) == 1: str
    else: str + "s"
    end
  end

  {v;f} = w
  time = v
  hfn = f
  height = hfn(time)
  speed = hfn(time + 1) - height
  ttime = beside(
    time-text("Time: " + tostring(time) + ss(time, "second")),
    scale(1.2, time-text("       [spacebar] adds one second.  [b] goes back!")))
  theight = height-text("Height: " + num-to-string-digits(height, 4) + ss(height, "meter"))
  light-text = if num-abs(speed) > 299792458:
    "  That's faster than light!"
  else:
    ""
  end
  tspeed = speed-text("Speed: " + num-to-string-digits(speed, 4) + ss(speed, "meter") + "/seconds"
      + light-text)
  above-align("left", ttime, above-align("left", theight, tspeed))
end

fun plain-draw(t, fn):
  PLAIN-WIDTH = 200
  place-image(
    ROCKET,
    PLAIN-WIDTH / 2,
    ROCKET-HEIGHT - fn(t),
    marks(0, ROCKET-HEIGHT, 50).foldr(
      lam(mark, bg):
        i = height-text(tostring(mark))
        place-image(i, image-width(i) / 2, (ROCKET-HEIGHT - mark) - 15, bg)
      end,
      empty-scene(PLAIN-WIDTH, ROCKET-HEIGHT)
      ))
end

fun rocket-draw-world(w):
  fun rocket-add(window):
    {time; hfn} = w
    height = hfn(time)
    rocket = scale(rocket-scale(height), ROCKET)
    rocket-pixh = universe-pix(height)
    usable-rocket-space = ROCKET-HEIGHT - UNIVERSE-ZERO-PX
    winh-p = 1 - ((BACKGROUND-PX-ABOVE-GROUND - rocket-pixh) / BACKGROUND-PX-ABOVE-GROUND)
    ydt = 0 - (winh-p * usable-rocket-space)
    y = usable-rocket-space + ydt
    bgy = rocket-pixh + ydt + (ROCKET-HEIGHT - (image-height(ROCKET-BG) / 2))
    place-image(rocket, CENTER, y, place-image(ROCKET-BG, CENTER, bgy, window))
  end

  rocket-add(rectangle(image-width(ROCKET-BG), ROCKET-HEIGHT, "solid", "white"))
end

fun universe-pix(h):
  ask:
    | h <= 0 then: h
    | otherwise:
      (num-log(1.1 + h) / LOG-UNIVERSE-HEIGHT) * BACKGROUND-PX-ABOVE-GROUND
  end
end

fun rocket-scale(height):
  k = 40
  h = 2 + num-abs(height)
  d = num-log(k * h)
  num-max(
    1/25,
    (d - num-log(h)) / d)
end

fun marks(start, stop, step):
  if start < stop:
    link(start, marks(start + step, stop, step))
  else:
    [list: stop]
  end
end

fun graph-draw-world(w):
  GRAPH-SIZE = 400
  GRAPH-LEGEND-SIZE = 20
  NUM-MARKS = 15

  fun plus-marks(start, stop, step):
    fun plus-marks-internal(shadow start, shadow stop, shadow step):
      if start < stop:
        link(start, marks(start + step, stop, step))
      else:
        [list: stop, stop + step]
      end
    end
    link(start - step, plus-marks-internal(start, stop, step))
  end

  {seconds; fn} = w
  x-step = num-max(1, num-round(num-abs(seconds) / NUM-MARKS))
  x-seconds = marks(num-min(0, seconds), num-max(0, seconds), x-step)
  y-outputs = map(fn, x-seconds)
  biggest-y = reduce(num-max, y-outputs)
  smallest-y = reduce(num-min, y-outputs)

  y-step = num-max(1, num-round((biggest-y - smallest-y) / NUM-MARKS))

  y-meters = plus-marks(smallest-y, biggest-y, y-step)

  max-seconds = reduce(num-max, x-seconds)
  min-seconds = reduce(num-min, x-seconds)
  x-range = num-max(1, max-seconds - min-seconds)
  max-meters = reduce(num-max, y-meters)
  min-meters = reduce(num-min, y-meters)

  y-range = num-max(1, max-meters - min-meters)
  x-pixel-position = lam(shadow seconds):
    (GRAPH-SIZE - GRAPH-LEGEND-SIZE) * ((seconds - min-seconds) / x-range)
  end
  y-pixel-position = lam(meters):
    GRAPH-SIZE - ((GRAPH-SIZE - GRAPH-LEGEND-SIZE) * ((meters - min-meters) / y-range))
  end
  rockets = x-seconds.foldr(
    lam(shadow seconds, bg):
      place-image(
        scale(1/5, ROCKET),
        x-pixel-position(seconds),
        y-pixel-position(fn(seconds)),
        bg)
    end,
    rectangle(GRAPH-SIZE, GRAPH-SIZE, "outline", "black")
    )
  x-legend = above(
    x-seconds.foldr(
      lam(shadow seconds, bg):
        place-image(
          time-text(tostring(seconds)),
          x-pixel-position(seconds),
          GRAPH-LEGEND-SIZE / 2,
          bg)
      end,
      rectangle(GRAPH-SIZE, GRAPH-LEGEND-SIZE, "solid", "white")
      ),
    time-text("seconds"))
  y-legend = beside(
    rotate(90, height-text("meters")),
    y-meters.foldr(
      lam(meters, bg):
        place-image(
          height-text(num-to-string-digits(meters, 2)),
          2.5 * GRAPH-LEGEND-SIZE,
          y-pixel-position(meters),
          bg)
      end,
      rectangle(5 * GRAPH-LEGEND-SIZE, GRAPH-SIZE, "solid", "white")
      ))
  beside-align("top", y-legend, above-align("right", rockets, x-legend))
end

fun combined-draw-world(w):
  {v;fn} = w
  above-align(
    "left",
    beside(
      plain-draw(v, fn),
      beside(
        rocket-draw-world(w),
        graph-draw-world(w))),
    above-align("left",
      legend(w),
      THANKS))
end

fun blastoff(fn) block:
  r = reactor:
    title: "Blastoff!",
    init: {0; fn},
    on-key: tock,
    to-draw: lam(w):
        {v;shadow fn} = w
        above(plain-draw(v, fn), legend(w))
      end,
  end
  t = r.interact-trace()
  t.build-column("height", lam(row): fn(row["tick"]) end)
    .drop("state")
    .rename-column("tick", "seconds")
end

fun space(fn) block:
  r = reactor:
    title: "Blastoff!",
    init: {0; fn},
    on-key: tock,
    to-draw: lam(w):
        above(
          rocket-draw-world(w),
          above(
            legend(w),
            THANKS))
      end,
  end
  t = r.interact-trace()
  t.build-column("height", lam(row): fn(row["tick"]) end)
    .drop("state")
    .rename-column("tick", "seconds")
end

fun graph(fn) block:
  r = reactor:
    title: "Blastoff!",
    init: {0; fn},
    on-key: tock,
    to-draw: lam(w): above(graph-draw-world(w), legend(w)) end,
  end
  t = r.interact-trace()
  t.build-column("height", lam(row): fn(row["tick"]) end)
    .drop("state")
    .rename-column("tick", "seconds")
end

fun everything(fn) block:
  r = reactor:
    title: "Blastoff!",
    init: {0; fn},
    on-key: tock,
    to-draw: combined-draw-world,
  end
  t = r.interact-trace()
  t.build-column("height", lam(row): fn(row["tick"]) end)
    .drop("state")
    .rename-column("tick", "seconds")
end

fun reduce(f, l):
  for fold(acc from l.first, elt from l.rest):
    f(acc, elt)
  end
end

fun sanity-checks():
  test-funs = [list:
    lam(s): 0 end,
    lam(s): 100 end,
    lam(s): 100000 end,
    lam(s): s * 7 end,
    lam(s): s * 17 end,
    lam(s): s * 0.7 end,
    lam(s): s * -7 end,
    lam(s): s / 3 end,
    lam(s): 500 + (s * -7) end,
    num-sqr
    #    lam(s): num-expt(s, 5) end,
    #|lam(s): num-expt(3.1415, s) end
    lam(s): num-expt(num-abs(s) + 1, -5) end,
    lam(s): num-expt(-2, s) end,
    lam(s): num-expt(s, 7) end,
    lam(s): num-expt(10, s) end|#
  ]
  times = [list: -10, -1, 0, 1, 2, 3, 5, 10, 30, 80, 200]
  fun at-times(test-fn):
    imgs = for map(elt from times):
      scale(1/8, combined-draw-world({elt;test-fn}))
    end
    reduce(beside, imgs)
  end
  reduce(
    above-align("left", _, _),
    map(at-times, test-funs))
end

