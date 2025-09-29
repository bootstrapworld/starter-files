use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

# animation that pulses a star as it goes across the sky

# a coord is an x-coordinate and a y-coordinate
data Coord:
  | coord(x :: Number,
      y :: Number)
end

# fixed images
BACKGROUND-IMG = rectangle(600,400,"solid","blue")

# a world is the star size, growth rate, and location
data World:
  | world(
      star-size :: Number,
      star-grow :: Number,
      star-loc :: Coord )
end

# make-star : number -> image
# given a radius, produce a yellow star of that size
fun make-star(radius):
  star(radius, "solid", "yellow")
end

# draw-world : World -> Image
# create an image from a world
fun draw-world(w):
  put-image(make-star(w.star-size),
    w.star-loc.x,
    w.star-loc.y,
    BACKGROUND-IMG)
end

# reverse-growth: Number Number -> Boolean
# determine whether to reverse direction that star is growing
fun reverse-growth(size, grow-rate):
  ((size < 20) and (grow-rate < 0)) or
  ((size > 50) and (grow-rate > 1))
end

# examples for reverse-growth
examples:
  reverse-growth(20, -1) is false
  reverse-growth(19, -1) is true
  reverse-growth(19, 1) is false
  reverse-growth(50, 2) is false
  reverse-growth(51, 2) is true
  reverse-growth(51, -1) is false
end

# next-world : World -> World
# given a world, produce the world for the next animation frame
fun next-world(w):
  world(w.star-size + w.star-grow,
    if (reverse-growth(w.star-size, w.star-grow)):
      w.star-grow * -1
    else:
      w.star-grow
    end,
    # wrap star around once it goes off the screen
    if (w.star-loc.x > 620):
      coord(0, 350)
    else:
      coord(w.star-loc.x + 2,
        w.star-loc.y - 1)
    end
    )
end

# data for testing
SMALL-STAR-WORLD = world(19, 1, coord(100,100))
OFF-RIGHT-WORLD = world(40, -1, coord(625, 200))

# examples for next-world
examples:
  next-world(SMALL-STAR-WORLD) is world(20, 1, coord(102, 99))
  next-world(OFF-RIGHT-WORLD) is world(39, -1, coord(0, 350))
end

# create the animation
r = reactor:
  init: world(35,2,coord(0,350)),
  on-tick: next-world,
  to-draw: draw-world
end

r.interact()