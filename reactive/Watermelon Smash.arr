use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

# A SmashState is the y-coordinate of a mallet, and a timer
data SmashState:
  | smash(
      mallety :: Number,
      timer :: Number)
end

START = smash(250, 0)

# IMAGES
BACKGROUND = square(400, "solid", "white")
WATERMELON = scale(0.3, image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/watermelon-melon.png"))
MALLET     = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/watermelon-mallet.png")
SMASHED    = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/watermelon-smashed.png")

# draw-state :: SmashState -> Image
# draws the image of the watermelon and mallet on the screen.
fun draw-state(a-smash):
  put-image(MALLET, 275, a-smash.mallety,
    put-image(WATERMELON, 200, 75, BACKGROUND))
end

# next-state-tick :: SmashState -> SmashState
# Decreases the y-coordinate of the mallet every tick
fun next-state-tick(a-smash):
  smash(a-smash.mallety - 2, a-smash.timer)
end


smash-react = reactor:
  init: START,
  to-draw: draw-state,
  on-tick: next-state-tick
end

interact(smash-react)


