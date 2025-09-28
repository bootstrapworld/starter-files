use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/projects/games/", "../../libraries/core.arr")
include url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/projects/games/", "../../libraries/game-library.arr")

# DO NOT MODIFY LINE 5
# its modifies the chart functions to generates image without popups
display-chart := lam(c): c.get-image() end
# A. Game title: Write the title of your game here
TITLE = "My Game"
TITLE-COLOR = "white"

# B. Graphics - Define your danger, target, projectile and player images
# You can replace any of the definitions below with other images
# And scale them to whatever size makes the most sense! 

BACKGROUND = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/projects/game/Night%20Forest.jpg")
DANGER = triangle(30, "solid", "red")
TARGET = circle(20, "solid", "yellow")
PLAYER = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/projects/game/Robot.png")

# C. Here's a screenshot of the game.
# The BACKGROUND is 640 x 480 with the characters placed on that field.
# The character's initial locations are:
# PLAYER (320, 240)
# TARGET (400 500)
# DANGER (150, 200)
# You can change the characters' coordinates in the code below to compose your image how you like it.

SCREENSHOT = 
  translate(DANGER, 150, 200,
    translate(TARGET, 400, 500, 
      translate(PLAYER, 320, 240, BACKGROUND)))

