use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

# Animation of a cyclist riding along a street

# A BikeState is the x-coordinate of a cyclist and the angle of wheel rotation.
data BikeState:
    bike(
      cyclistx :: Number,
      rotation :: Number)
end

# Images go here
BICYCLE = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/bicycle.png")
WHEEL   =  image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/bicycle-wheel.png")
BACKGROUND = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/bicycle-town.png")
INIT-STATE = bike(100, 0)
FRAMEY = image-height(BACKGROUND) / 3 # y-coordinate of bicycle frame

# draw-state : BikeState -> Image
# Draws the image of the cyclist and wheels on the background
fun draw-state(bs):
  put-image(rotate(bs.rotation, WHEEL),
    bs.cyclistx - 40, FRAMEY - 40,
    put-image(rotate(bs.rotation, WHEEL),
      bs.cyclistx + 38, FRAMEY - 40,
      put-image(BICYCLE,
        bs.cyclistx, FRAMEY,
        BACKGROUND)))
end

# next-state-tick : BikeState -> BikeState
# Check to see if the cyclist is off the screen, otherwise rotate the wheels and increase the x-coordinate of the bike


# Starting the animation
r = reactor:
  init: INIT-STATE,
  to-draw: draw-state,
  #  on-tick: next-state-tick
end

r.interact()