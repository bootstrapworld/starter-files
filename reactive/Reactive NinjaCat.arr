use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

data GameState:
  | world(
      dangerx :: Number,
      targetx :: Number,
      playerx :: Number,
      playery :: Number)
end

# Define a bunch of images that we can use later
PLAYER      = scale(0.4, image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries/images/ninjacat.png"))
CLOUD       = scale(0.5, image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries/images/clouds.png"))
TARGET      = scale(0.4, image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries/images/ruby.png"))
DANGER      = scale(0.5, image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries/images/dog.png"))
BACKGROUND-IMG = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries/images/bg.png")

# Some instances of the world for testing
initial-scene = world(300, 300, 150, 100)
middle-scene = world(150, 200, 75, 75)

####################
# GRAPHICS FUNCTIONS
####################

# draw-world : Number -> Image
# Place DANGER onto BACKGROUND at the right coordinates
fun draw-world(current-world):
  put-image(PLAYER, current-world.playerx, current-world.playery,
    put-image(TARGET, current-world.targetx, 200,
      put-image(DANGER, current-world.dangerx, 400, BACKGROUND-IMG)))
end

####################
# UPDATING FUNCTIONS
####################

examples:
  next-world(initial-scene)
    is world(
    initial-scene.dangerx - 10,
    initial-scene.targetx - 5,
    initial-scene.playerx,
    initial-scene.playery)

  next-world(middle-scene)
    is world(
    middle-scene.dangerx - 10,
    middle-scene.targetx - 5,
    middle-scene.playerx,
    middle-scene.playery)

end

# next-world : Number -> Number
# Add 10 dog's x-coordinate
fun next-world(current-world):
  world(
    current-world.dangerx - 10,
    current-world.targetx - 5,
    current-world.playerx,
    current-world.playery)
end

# keypress : World, String -> World
# Move the cat in one of four directions based on which arrow key is pressed,
# leave it in place otherwise.
examples:
  keypress(initial-scene, "left")
    is world(
    initial-scene.dangerx,
    initial-scene.targetx,
    initial-scene.playerx - 5,
    initial-scene.playery)

  keypress(initial-scene, "right")
    is world(
    initial-scene.dangerx,
    initial-scene.targetx,
    initial-scene.playerx + 5,
    initial-scene.playery)

  keypress(initial-scene, "down")
    is world(
    initial-scene.dangerx,
    initial-scene.targetx,
    initial-scene.playerx,
    initial-scene.playery - 5)

  keypress(initial-scene, "up")
    is world(
    initial-scene.dangerx,
    initial-scene.targetx,
    initial-scene.playerx,
    initial-scene.playery + 5)

  keypress(initial-scene, "z")
    is world(
    initial-scene.dangerx,
    initial-scene.targetx,
    initial-scene.playerx,
    initial-scene.playery)
end

fun keypress(current-world, key):
  ask:
    | string-equal(key, "left") then:
      world(
        current-world.dangerx,
        current-world.targetx,
        current-world.playerx - 5,
        current-world.playery)
    | string-equal(key, "right") then:
      world(
        current-world.dangerx,
        current-world.targetx,
        current-world.playerx + 5,
        current-world.playery)
    | string-equal(key, "up") then:
      world(
        current-world.dangerx,
        current-world.targetx,
        current-world.playerx,
        current-world.playery + 5)
    | string-equal(key, "down") then:
      world(
        current-world.dangerx,
        current-world.targetx,
        current-world.playerx,
        current-world.playery - 5)
    | otherwise: current-world
  end
end

game-react = reactor:
  init: initial-scene,
  on-tick: next-world,
  on-key: keypress,
  to-draw: draw-world
end

game-react.interact()