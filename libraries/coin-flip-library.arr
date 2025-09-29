use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "core.arr")

################################################################
# Bootstrap Plagiarism Library, as of Fall 2026

provide *

# The actual program
fun flip(head-odds) block:
  # Some convenient constants
  RADIANS = PI / 180
  SCALE = 150

  color = if (head-odds() == 50): "dark-orange"
  else if (head-odds() == 90): "gold"
  else if (head-odds() == 75): "yellow" end

  COIN = overlay(
    circle(SCALE - (SCALE / 16), "outline", "black"),
    overlay(circle(SCALE, "outline", "black"),
      circle(SCALE, "solid", color)))
  HEADS = put-image(text("Heads!", SCALE / 2, "black"), SCALE, SCALE, COIN)
  TAILS = put-image(text("Tails!", SCALE / 2, "black"), SCALE, SCALE, COIN)

  fun flip-random():
    if (num-random(100) > 50): "heads"
    else: "tails"
    end
  end

  fun flip-biased():
    if (num-random(100) < head-odds()): "heads"
    else: "tails"
    end
  end

  fun draw-coin(f):
    if (f() == "heads"): HEADS
    else: TAILS
    end
  end

  fun draw-world(t):
    overlay(
      if (t > 0): scale-xy(1, num-sin(t * RADIANS), draw-coin(flip-random))
      else: draw-coin(flip-biased)
      end,
      square((2 * SCALE) + 10, "solid", "white"))
  end

  r = reactor:
    init:720,
    seconds-per-tick: 0.02,
    to-draw: draw-world,
    on-tick: lam(t): t - 15 end,
    stop-when: lam(t): t < 0 end
  end
  r.interact()
  nothing
end

# each "coin" is just a function that
# hides the %chance of getting heads
fun coin1(): 90 end
fun coin2(): 50 end
fun coin3(): 75 end