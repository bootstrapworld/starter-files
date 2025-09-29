use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

# animation for pong with one paddle , controlled by the player

# a coord is an x-coordinate and a y-coordinate
data Coord:
  | coord(
      x :: Number,
      y :: Number)
end

# a vector is a change in each of the x-direction and the y-direction
data Vec:
  | vec(
      x :: Number,
      y :: Number)
end

# a world is a ball coordinate, ball movement vector, and paddle coordinate
data World:
  | world(
      ball-pos :: Coord,
      ball-vec :: Vec,
      paddle-pos :: Coord)
end

# -- the constants ----------

# fixed dimensions
BOARD-WIDTH = 400
BOARD-HEIGHT = 400

# fixed images
BACKGROUND = rectangle(BOARD-WIDTH, BOARD-HEIGHT, "solid", "gray")
BALL = circle(12, "solid", "yellow")
PADDLE = rectangle(15, 60, "solid", "magenta")

# sample coords for writing examples
RIGHT-EDGE-COORD = coord(BOARD-WIDTH, 20)
TOP-EDGE-COORD = coord(20, BOARD-HEIGHT)
BOT-EDGE-COORD = coord(20, 0)
OFF-LEFT-COORD = coord(-10, 100)
MID-BOARD-COORD = coord(100, 100)
INIT-PADDLE-COORD = coord(20, 200)

# sample worlds
INIT-WORLD = world(MID-BOARD-COORD, vec(4, -4), INIT-PADDLE-COORD)
OFF-LEFT-WORLD = world(OFF-LEFT-COORD, vec(4, -4), INIT-PADDLE-COORD)

# -- the functions ---------

# draw-world : World -> Image
# create an image with the paddle and ball on the background screen
fun draw-world(w):
  put-image(BALL, w.ball-pos.x, w.ball-pos.y,
    put-image(PADDLE, w.paddle-pos.x, w.paddle-pos.y,
      BACKGROUND))
end

# move-paddle: World String -> World
# produce world for next game frame based on key press that moves the paddle
fun move-paddle(w, key):
  world(w.ball-pos, w.ball-vec,
    coord(w.paddle-pos.x,
      w.paddle-pos.y +
      ask:
        | string-equal(key, "up") then: 5
        | string-equal(key, "down") then: -5
        | otherwise: 0
      end
      ))
end

# new-ball : Coord Vec -> Coord
# produce ball with position of given ball as adjusted by the vector
fun new-ball(bpos, bvec):
  coord(bpos.x + bvec.x,
    bpos.y + bvec.y)
end

# new-ball examples
examples:
  new-ball(coord(100,100), vec(2, 3)) is coord(100 + 2, 100 + 3)
  new-ball(coord(0,0), vec(-4, 0)) is coord(0 + -4, 0 + 0)
end

# ball-hit-right: Coord -> Boolean
# check whether ball has hit the right edge
fun ball-hit-right(bpos):
  (bpos.x + (image-width(BALL) / 2)) >= BOARD-WIDTH
end

# ball-hit-bot: Coord -> Boolean
# check whether ball has hit the bottom edge
fun ball-hit-bot(bpos):
  (bpos.y - (image-height(BALL) / 2)) <= 0
end

# ball-hit-top: Coord -> Boolean
# check whether the ball has hit the top edge
fun ball-hit-top(bpos):
  (bpos.y + (image-height(BALL) / 2)) >= BOARD-HEIGHT
end

# ball-off-left: Coord -> Boolean
# check whether ball has gone off the left edge of the board
fun ball-off-left(w):
  w.ball-pos.x <= 0
end

# examples for multiple functions that detect balls at edges
examples:
  ball-hit-right(RIGHT-EDGE-COORD) is true  # ball at right edge
  ball-hit-right(coord(385, 200)) is false # ball near, but not at, right edge
  ball-hit-right(coord(200, 600)) is false # ball offscreen, but not on right

  ball-hit-top(TOP-EDGE-COORD) is true  # ball at top edge
  ball-hit-top(coord(100, 385)) is false # ball near, but not at, top edge
  ball-hit-top(coord(600, 100)) is false # ball offscreen, but not on top

  ball-hit-bot(BOT-EDGE-COORD) is true  # ball at bottom edge
  ball-hit-bot(coord(100, 15)) is false # ball near, but not at, bottom edge
  ball-hit-bot(coord(600, 100)) is false # ball offscreen, but not on bottom

  ball-off-left(INIT-WORLD) is false
  ball-off-left(OFF-LEFT-WORLD) is true
end

# ball-hit-paddle: Coord Coord -> Boolean
# check whether the ball has hit the paddle
fun ball-hit-paddle(bpos, ppos):
  ball-left = bpos.x - (image-width(BALL) / 2)
  paddle-right = ppos.x + (image-width(PADDLE) / 2)
  paddle-top = ppos.y + (image-height(PADDLE) / 2)
  paddle-bot = ppos.y - (image-height(PADDLE) / 2)

  (bpos.y >= paddle-bot) and
  (bpos.y <= paddle-top) and
  (ball-left <= paddle-right)
end

# ball-hit-paddle tests
examples:
  ball-hit-paddle(coord(20,200), coord(20,200)) is true
  ball-hit-paddle(coord(120,200), coord(20,200)) is false
end

# compute the new directional vector for the ball.
# the vector changes if the ball has bounced off of
#   either an edge or a paddle
fun new-vec(bpos, bvec, ppos):
  vec(if (ball-hit-right(bpos) or ball-hit-paddle(bpos, ppos)):
    bvec.x * -1 else: bvec.x end,
      if (ball-hit-top(bpos) or ball-hit-bot(bpos)):
        bvec.y * -1
      else: bvec.y
    end)
end

# new-vec tests
examples:
  new-vec(TOP-EDGE-COORD, vec(-1, -1), INIT-PADDLE-COORD) is vec(-1, 1)
  new-vec(BOT-EDGE-COORD, vec(-1, -1), INIT-PADDLE-COORD) is vec(-1, 1)
  new-vec(RIGHT-EDGE-COORD, vec(-1, -1), INIT-PADDLE-COORD) is vec(1, -1)
end

# next-world : World -> World
# the ball moves according to the vector on ticks, the
# vector changes when the ball hits the edge
fun next-world(w):
  next-vec = new-vec(w.ball-pos, w.ball-vec, w.paddle-pos)
  world(new-ball(w.ball-pos, next-vec),
    next-vec,
    w.paddle-pos)
end

# next-world tests
examples:
  next-world(world(coord(200, 100), vec(4, -4), INIT-PADDLE-COORD)) is
  world(coord(200 + 4, 100 + -4), vec(4, -4), INIT-PADDLE-COORD)
end

r = reactor:
  init: INIT-WORLD,
  to-draw: draw-world,
  on-key: move-paddle,
  on-tick: next-world,
  stop-when: ball-off-left
end

r.interact()