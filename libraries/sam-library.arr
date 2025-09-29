use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "core.arr")

################################################################
# Sam the Butterfly support file, as of Fall 2026

provide *

# export every symbol from starter2024 except for those we override
import starter2024 as Starter
provide from Starter: * hiding(translate, filter, range, sort) end

################################################################
######################### SAM THE BUTTERFLY ####################
SAM-WIDTH = 640
SAM-HEIGHT = 480

type SamWorld = {x :: Number, y :: Number, img :: Image}

fun move(w, key):
  ask:
    | key == "left"  then: w.{x: w.x - 10}
    | key == "right" then: w.{x: w.x + 10}
    | key == "up"    then: w.{y: w.y + 10}
    | key == "down"  then: w.{y: w.y - 10}
    | otherwise: w
  end
end

fun draw-sam(w):
  fun draw-butterfly(shadow w, scene):
    place-image(w.img, w.x, SAM-HEIGHT - w.y, scene)
  end
  fun draw-text(shadow w, scene):
    place-image(text(
        "x-coordinate: " + tostring(w.x) + "   y-coordinate: " + tostring(w.y),
        14,
        "black"),
      num-floor(image-width(scene) / 2),
      15,
      scene)
  end
  draw-butterfly(w, draw-text(w, empty-scene(SAM-WIDTH, SAM-HEIGHT)))
end

fun normalize-onscreen(fn):
  cases(TaggedFunction) guess-arity(fn):
    | one(f) => lam(x,y): f(x) end
    | two(f) => f
  end
end


fun sam(is-onscreen, img) block:
  shadow is-onscreen = normalize-onscreen(is-onscreen)
  update = lam(w, k):
    if is-onscreen(move(w, k).x, move(w, k).y):
      move(w, k)
    else:
      w
    end
  end
  r = reactor:
    title: "Sam the Butterfly",
    init: {x: SAM-WIDTH / 2, y:SAM-HEIGHT / 2, img:img},
    to-draw: draw-sam,
    on-key: update,
  end
  r.interact()
  nothing
end


fun trace(is-onscreen, img):
  shadow is-onscreen = normalize-onscreen(is-onscreen)
  update = lam(w, k):
    if is-onscreen(move(w, k).x, move(w, k).y):
      move(w, k)
    else:
      w
    end
  end
  R.interact-trace(reactor:
      init: {x: SAM-WIDTH / 2, y:SAM-HEIGHT / 2, img:img},
      to-draw: draw-sam,
      on-key: update
    end)
    .build-column("x", {(r): r["state"].x})
    .build-column("y", {(r): r["state"].y})
    .drop("state")
end

