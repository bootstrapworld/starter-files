use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

# simple animation to control lightbulb with a slider

# fixed dimensions
BAR-WIDTH = 70

# fixed images
BACKGROUND = rectangle(200, 200, "solid", "purple")
SLIDER-BAR = rectangle(BAR-WIDTH, 3, "solid", "gray")
SLIDER-BUTTON = rectangle(7, 20, "solid", "gray")

# a coord is an x-coordinate and a y-coordinate
data Coord:
  | coord(
      x :: Number,
      y :: Number)
end

# a world is the x-coordinate of the slider
data World:
  | world(slider-x :: Number)
end

# make-bulb: Number -> Image
# produce a circle using the slider value to determine transparency
fun make-bulb(slider-x):
  circle(30, (slider-x * 4) / ~255, "white")
end

# draw-world : World -> Image
# create an image from a world
fun draw-world(w):
  put-image(text("Press left and right", 18, "black"), 100, 90,
    put-image(text("to adjust the light", 18, "black"), 100, 70,
      put-image(make-bulb(w.slider-x), 100, 150,
        put-image(SLIDER-BUTTON, w.slider-x + 71, 30,
          put-image(SLIDER-BAR, 102, 20, BACKGROUND)))))
end

# move-slider: World, String -> World
# produce world for next frame, based on the key press
fun move-slider(w, key):
  ask:
    | string-equal(key, "left") then:
      world(num-max(w.slider-x - 2, 0))
    | string-equal(key, "right") then:
      world(num-min(w.slider-x + 2, 63))
    | otherwise: w.slider-x
  end
end

# tests for move-slider
examples:
  move-slider(world(10), "right") is world(12)
  move-slider(world(10), "left") is world(8)
  move-slider(world(0), "left") is world(0)
  move-slider(world(63), "right") is world(63)
  move-slider(world(64), "right") is world(63)
end

# define the reactor
r = reactor:
  init: world(63),
  to-draw: draw-world,
  on-key: move-slider
end

# run the slider application
r.interact()