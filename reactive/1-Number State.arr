use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

# next-state-tick :: Number -> Number
fun next-state-tick(n):
  n + 1
end

# draw-state :: Number -> Image
fun draw-state(n):

  "fix me!"

end

r = reactor:
  init: 1,
  # to-draw: draw-state,
  on-tick: next-state-tick
end

r.interact()