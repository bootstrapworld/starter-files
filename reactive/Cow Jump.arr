use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

# animation of cow jumping over moon, changing shape as it flies over

# a coord is an x-coordinate and a y-coordinate
data Coord:
  | coord(x :: Number,
      y :: Number)
end

# a world is a cow coordinate and the image to use for the cow
data World:
  | world(
      cow-pos :: Coord,
      cow-img :: Image)
end

# fixed dimensions
MOON-CENTER-X = 300 # the x-coordinate of the moon
SCREEN-WIDTH = 600

# fixed images
BACKGROUND = rectangle(SCREEN-WIDTH, 400, "solid", "light blue")
MOON = circle(50, "solid", "gray")
COW-FLY = scale(0.15, image-url(""https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/cow.png""))

COW-JUMP = flip-horizontal(scale(0.15,
    image-url(""https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/cow-jump.png"")))

# touch-moon-left: Coord -> Boolean
# determine whether cow is touching the moon's left side given cow coordinate
fun touch-moon-left(cp):
  moon-left-edge = MOON-CENTER-X - (image-width(MOON) / 2)
  cowxdelta = (cp.x + (image-width(COW-FLY) / 2)) - moon-left-edge
  (-4 <= cowxdelta) and (cowxdelta <= 0)
end

# toucb-moon-left tests
examples:
  touch-moon-left(coord(173,100)) is false
  touch-moon-left(coord(178,100)) is true
  touch-moon-left(coord(182,100)) is false
end

# passed-moon-right: Coord -> Boolean
# determine whether cow has passed the moon's right side given cow coordinate
fun passed-moon-right(cp):
  moon-right-edge = MOON-CENTER-X + (image-width(MOON) / 2)
  cowxdelta = (cp.x - (image-width(COW-FLY) / 2)) - moon-right-edge
  (0 <= cowxdelta) and (cowxdelta <= 4)
end

examples:
  passed-moon-right(coord(400, 100)) is false
  passed-moon-right(coord(422, 100)) is true
end

# cow-offscreen: Coord -> Boolean
# determine whether the cow has flown offscreen a bit
fun cow-offscreen(cp):
  cp.x > (SCREEN-WIDTH + image-width(COW-FLY))
end

# cow-offscreen examples
examples:
  cow-offscreen(coord(750,100)) is true
  cow-offscreen(coord(SCREEN-WIDTH, 100)) is false
end

# draw-world : World -> Image
# create an image with the moon and cow, taking cow image from the world
fun draw-world(w):
  put-image(w.cow-img, w.cow-pos.x, w.cow-pos.y,
    put-image(MOON, MOON-CENTER-X, 200, BACKGROUND))
end

# next-world : World -> World
# given a world, produce the world for the next animation frame
fun next-world(w):
  ask:
    | touch-moon-left(w.cow-pos) then:
      world(coord(w.cow-pos.x + 3, w.cow-pos.y + (image-height(MOON) / 2)), COW-JUMP)
    | passed-moon-right(w.cow-pos) then:
      world(coord(w.cow-pos.x + 3, w.cow-pos.y - (image-height(MOON) / 1)), COW-FLY)
    | cow-offscreen(w.cow-pos) then:
      world(coord(0 - (image-width(COW-FLY) / 2), 200), COW-FLY)
    | otherwise:
      world(coord(w.cow-pos.x + 3, w.cow-pos.y), w.cow-img)
  end
end

examples:
  next-world(world(coord(100, 100), COW-FLY)) is world(coord(100 + 3, 100), COW-FLY)
  next-world(world(coord(178, 100), COW-FLY)) is world(coord(178 + 3, 100 + (image-height(MOON) / 2)), COW-JUMP)
  next-world(world(coord(422, 100), COW-JUMP)) is world(coord(422 + 3, 100 - image-height(MOON)), COW-FLY)
end

# start the animation
r = reactor:
  init: world(coord(10,200), COW-FLY),
  to-draw: draw-world,
  on-tick: next-world
end

r.interact()