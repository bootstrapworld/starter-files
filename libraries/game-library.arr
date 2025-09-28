use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/libraries/", "core.arr")

################################################################
# Bootstrap Game Library, as of Fall 2026

provide *

# export every symbol from starter2024 except for those we override
import starter2024 as Starter
provide from Starter:
  * hiding(translate, filter, range, sort, sin, cos, tan)
end

################################################################
########################### THE VIDEOGAME ######################

GAME-WIDTH       = 640
GAME-HEIGHT      = 480
EXPLOSION-COLOR  = "gray"
var _TITLE-COLOR = "white"
var _BACKGROUND  = rectangle(GAME-WIDTH, GAME-HEIGHT, "solid", "black")

fun spacing(): 100 + random(200) end

_target-increment_ = 20
_danger-increment_ = -50
LOSS-SCORE = 0
GAMEOVER_IMG = image-url("http://www.wescheme.org/images/teachpacks2012/gameover.png")

var _score_    = 0
var _player-x_ = 0
var _player-y_ = 0

var _line-length_ = lam(a, b): 0 end
var _distance_    = lam(px, cx, py, cy): 0 end
var _DISTANCES-COLOR_ = ""

TOLERANCE = 20

RESTING-TOP-DOWN-ORIENTATION = 40

fun fit-image-to(w, h, an-image):
  height-scaled = ((w / h) * image-height(an-image))
  ask:
    | image-width(an-image) == height-scaled then:
      scale(image-width(an-image) / w, an-image)
    | image-width(an-image) > height-scaled then:
      scale(
        w / ((w / h) * image-height(an-image)),
        crop(0, 0, (w / h) * image-height(an-image), image-height(an-image), an-image))
    | image-width(an-image) < height-scaled then:
      scale(
        w / image-width(an-image),
        crop(0, 0, image-width(an-image), (h / w) * image-width(an-image), an-image))
  end
end

fun cull(beings :: L.List<Being>) -> L.List<Being>:
  for filter(b from beings):
    p = b.posn
    (p.x > 0) and (p.x < GAME-WIDTH) and
    (p.y > 0) and (p.y < GAME-HEIGHT)
  end
end

data Being:
  | being(posn :: Posn, costume :: Image, cullable :: Boolean)
end

type world = {
  dangers :: L.List<Being>,
  shots   :: L.List<Being>,
  targets :: L.List<Being>,
  player  :: Being,
  bg      :: Image,
  score   :: Number,
  title   :: String,
  timer   :: Number
}

fun posn-to-point(p :: Posn) -> Posn:
  posn(p.x, GAME-HEIGHT - p.y)
end

fun add-informative-triangle(
    cx :: Number,
    cy :: Number,
    shadow color :: String,
    background):

  player-point = posn-to-point(posn(_player-x_, _player-y_))
  px = player-point.x
  py = player-point.y
  if (px == cx) and (py == cy):
    background
  else:
    dx = cx - px
    dy = cy - py
    n-to-s = lam(num): tostring(num-exact(num-round(num))) end
    place-image(
      text(n-to-s(_line-length_(cx, px)), 12, color),
      cx - (dx / 2),
      cy,
      place-image(
        line(dx, 0, color),
        cx - (dx / 2),
        cy,
        place-image(
          text(n-to-s(_line-length_(cy, py)), 12, color),
          px,
          cy - (dy / 2),
          place-image(
            line(0, dy, color),
            px,
            cy - (dy / 2),
            place-image(
              text(n-to-s(_distance_(px, py, cx, cy)), 12, color),
              cx - (dx / 2),
              cy - (dy / 2),
              place-image(
                line(dx, dy, color),
                cx - (dx / 2),
                cy - (dy / 2),
                background))))))
  end
end

fun draw-being(b :: Being, background):
  screen-point = posn-to-point(b.posn)
  cx = screen-point.x
  cy = screen-point.y
  dbg-bkgnd = if not(_DISTANCES-COLOR_ == ""):
    add-informative-triangle(cx, cy, _DISTANCES-COLOR_, background)
  else:
    background
  end
  translate(b.costume, b.posn.x, b.posn.y, dbg-bkgnd)
end

fun draw-game(w :: world):
  score-string = w.title + "                    score:" + tostring(w.score)
  player = if w.timer > 0:
    being(w.player.posn, radial-star(7, 1.5 * w.timer, 0.25 * w.timer, "solid", EXPLOSION-COLOR), w.player.cullable)
  else:
    w.player
  end
  all-beings = w.targets + w.dangers + w.shots + [list: player]
  block:
    # update globals in case students want to use them
    _player-x_ := w.player.posn.x
    _player-y_ := w.player.posn.y
    _score_ := w.score
    if w.score <= 0:
      GAMEOVER_IMG
    else:
      translate(
        text-font(score-string, 18, _TITLE-COLOR, "default", "default", "italic", "bold", true),
        num-floor(image-width(_BACKGROUND) / 2),
        image-height(_BACKGROUND) - 20,
        all-beings.foldl(draw-being, _BACKGROUND))
    end
  end
end



fun make-game(title, title-color, background,
    dangerImgs, update-danger,
    targetImgs, update-target,
    playerImg, update-player,
    projectileImgs, update-projectile,
    show-distances, line-length, distance,
    collide, onscreen):
  [list:
    title, title-color, background,
    dangerImgs, update-danger,
    targetImgs, update-target,
    playerImg, update-player,
    projectileImgs, update-projectile,
    show-distances, line-length, distance,
    collide, onscreen]
end

# finally, we normalize all animation functions to take both x and y
fun normalize-npc(fn):
  cases(TaggedFunction) guess-arity(fn):
    | one(f) => lam(x,y): posn(f(x), y) end
    | two(f) => f
  end
end
fun normalize-player(fn):
  cases(TaggedFunction) guess-arity(fn):
    | two(f) => lam(x, y, k): posn(x, f(y, k)) end
    | three(f) => f
  end
end

fun wrap-npc-for-being(f) -> (Being -> Being):
  lam(b):
    new-posn = f(b.posn.x, b.posn.y)
    if is-posn(new-posn):
      being(new-posn, b.costume, b.cullable)
    else if is-number(new-posn):
      being(posn(new-posn, b.posn.y), b.costume, b.cullable)
    else:
      raise("update-danger or update-target returned something other than a posn or number")
    end
  end
end

fun normalize-onscreen(fn):
  cases(TaggedFunction) guess-arity(fn):
    | one(f) => lam(x,y): f(x) end
    | two(f) => f
  end
end

fun wrap-player-for-being(f):
  lam(p, k):
    result = f(p.posn.x, p.posn.y, k)
    if is-number(result):
      being(posn(p.posn.x, result), p.costume, p.cullable)
    else if is-posn(result):
      being(result, p.costume, p.cullable)
    else:
      raise("update-player didn't return a posn or number")
    end
  end
end

# passes all the args to animate-proc, wrapping all the animation
# functions so they take in a consistent number of args regardless
# of arity. This allows kids to write simple functions first, then
# make them more complex
fun play(g) block:
  animate-proc(
    g.get(0), # title
    g.get(1), # title-color
    g.get(2), # background
    g.get(3), # dangerImgs
    wrap-npc-for-being(normalize-npc(g.get(4))), # update-danger
    g.get(5), # targetImgs
    wrap-npc-for-being(normalize-npc(g.get(6))), # update-target
    g.get(7), # playerImg
    wrap-player-for-being(normalize-player(g.get(8))), # update-player
    g.get(9), # projectileImgs
    wrap-npc-for-being(normalize-npc(g.get(10))),# update-projectile
    g.get(11),# distances-color
    g.get(12),# line-length
    g.get(13),# distance
    g.get(14),# collide
    normalize-onscreen(g.get(15)) # onscreen
    )
  nothing
end

fun flatten(x):
  ask:
    | is-empty(x) then: empty
    | not(is-link(x)) then: [list: x]
    | otherwise: flatten(x.first) + flatten(x.rest)
  end
end

fun animate-proc(title, title-color, background,
    dangerImgs, update-danger,
    targetImgs, update-target,
    playerImg, update-player,
    projectileImgs, update-projectile,
    distances-color, line-length, distance,
    collide, onscreen) block:
  # TODO(joe): error checking


  _TITLE-COLOR  := title-color
  _BACKGROUND   := fit-image-to(GAME-WIDTH, GAME-HEIGHT, background)
  _line-length_ := line-length
  _distance_    := distance
  _DISTANCES-COLOR_ := distances-color

  fun reset(b :: Being, f :: (Being -> Being)) -> Being:
    next-posn = f(being(posn(1, 1), empty-image, false)).posn
    next-x = next-posn.x - 1
    next-y = next-posn.y - 1
    random-posn = if num-abs(next-y) > num-abs(next-x):
      if next-y < 0:
        posn(num-random(GAME-WIDTH), spacing() + GAME-HEIGHT)
      else:
        posn(num-random(GAME-WIDTH), spacing() * -1)
      end
    else:
      if next-x < 0:
        posn(spacing() + GAME-WIDTH, num-random(GAME-HEIGHT))
      else:
        posn(spacing() * -1, num-random(GAME-HEIGHT))
      end
    end
    being(random-posn, b.costume, false)
  end

  player = being(
    posn(GAME-WIDTH / 2, GAME-HEIGHT / 2),
    center-pinhole(playerImg),
    false)
  is-onscreen = lam(b): onscreen(b.posn.x, b.posn.y) end
  is-collision = lam(b1, b2): collide(b1.posn.x, b1.posn.y, b2.posn.x, b2.posn.y) end

  is-hit-by = lam(b, enemies): L.any(lam(e): is-collision(b, e) end, enemies) end
  reset-chars = lam(chars, enemies, update):
    #|
       for each character....
       1) if it's been hit, reset it
       2) if it's onscreen, update it and make sure cullable=true
       3) if it's not cullable, update it as-is
       4) if it's not hit or onscreen, AND it's cullable - reset
    |#
    for map(b from chars) block:
      if is-hit-by(b, enemies):
        reset(b, update)
      else if is-onscreen(b):
        update(being(b.posn, b.costume, true))
      else if not(b.cullable):
        update(b)
      else:
        reset(b, update)
      end
    end
  end

  init-world = {
    dangers: for map(img from flatten([list: dangerImgs])):
        reset(being(posn(0, 0), center-pinhole(img), false), update-danger)
      end,
    shots: empty,
    targets: for map(img from flatten([list: targetImgs])):
        reset(being(posn(0, 0), center-pinhole(img), false), update-target)
      end,
    player: player,
    bg: background,
    score: 100,
    title: title,
    timer: 0
  }

  shadow key-press = lam(w, key):
    ask:
      | (key == " ") and (w.score <= LOSS-SCORE) then: init-world
      | w.score <= LOSS-SCORE then: w
      | key == "release" then: w
      | key == "escape" then: w.{timer: -1}
        # TODO(joe): missing a check here to do with noticing update-projectile
      | key == " " then:
        w.{shots: link(being(posn(_player-x_, _player-y_), projectileImgs, false), w.shots)}
      | otherwise: w.{player:update-player(w.player, key)}
    end
  end

  update-world = lam(w):

    hitables = link(w.player, w.shots)
    shadow dangers = reset-chars(w.dangers, hitables, update-danger)
    was-hit = L.any(lam(s): is-hit-by(s, w.dangers) end, w.shots)
    score = w.score + if was-hit: _target-increment_ else: 0 end
    shootables = w.dangers + w.targets

    next-world = w.{
      dangers: dangers,
      shots:   reset-chars(cull(w.shots), shootables, update-projectile),
      targets: reset-chars(w.targets, hitables, update-target),
      score:   score
    }

    ask:
      | w.score <= LOSS-SCORE then: w
      | w.timer > 0 then: next-world.{timer: w.timer - 10}
      | is-hit-by(w.player, w.dangers) then:
        next-world.{score: score + _danger-increment_, timer: 100}
      | is-hit-by(w.player, w.targets) then:
        next-world.{score: score + _target-increment_}
      | otherwise:
        next-world
    end
  end

  r = reactor:
    title: title,
    init: init-world,
    stop-when: lam(w): w.timer == -1 end,
    on-tick: update-world,
    seconds-per-tick: 0.1,
    to-draw: draw-game,
    on-key: key-press
  end
  r.interact()
  nothing
end

