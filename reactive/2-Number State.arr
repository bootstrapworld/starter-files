use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

data AnimationState:
  | state(
      a :: Number,
      b :: Number)
end

START = state(1, 100)

# next-state-tick :: AnimationState -> AnimationState
fun next-state-tick(s):
  state(s.a + 1, s.b - 1)
end

# draw-state :: AnimationState -> Image
fun draw-state(s):

  "fix me!"

end

r = reactor:
  init: START,
# to-draw: draw-state,
  on-tick: next-state-tick
end

r.interact()