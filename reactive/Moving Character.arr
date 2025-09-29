use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

data CharState:
  | char(x :: Number, y :: Number)
end

bottom-left = char(0, 0)
top-right = char(640, 480)

sam = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/algebra/inequalities/sam.png")


# draw-state : CharState -> Image
# puts Sam on a 640x480 rectangle,
# at the character's (x,y) position
fun draw-state(a-char):
  put-image(sam, a-char.x, a-char.y, rectangle(640, 480, "solid", "white"))
end


# next-state-key :: CharState, String -> CharState
# Moves the character by 5 pixels
# in the corresponding direction
# if an arrow key ("up", "left", "down", or "right")
# is pressed, & leaves the character in place otherwise



