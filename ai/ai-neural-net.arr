use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")

# ============================================================
#  xor-demo.arr  —  a 2-2-1 sigmoid network that computes XOR.
#
#  Weights are set by hand (no training yet) so we can confirm
#  the forward pass works end-to-end.  Once Units 6-7 land, we'll
#  re-do this demo by training the same architecture from random
#  weights.
#
#  Architecture:
#                            +--->  [ hidden-or   ]  --\
#         (x1, x2) inputs ---+                          +--->  [ output-and ]  --> y
#                            +--->  [ hidden-nand ]  --/
#
#  Idea:  XOR  =  (x1 OR x2)  AND  (NOT (x1 AND x2))
#                   ^^^^^^^^         ^^^^^^^^^^^^^^^
#                   hidden-or         hidden-nand
#                              AND-ed by output-and
# ============================================================
 
# We use weights of ±50 so the sigmoid saturates close to 0 or 1.
# That gives crisp outputs we can confirm with `is-roughly`.
 
hidden-or = make-neuron(
  table: input-name :: String, weight :: Number
    row: "x1",  50
    row: "x2",  50
  end,
  -25,
  "sigmoid")
 
hidden-nand = make-neuron(
  table: input-name :: String, weight :: Number
    row: "x1", -50
    row: "x2", -50
  end,
  75,
  "sigmoid")
 
hidden-layer = [list: hidden-or, hidden-nand]
 
# Output: AND on the two hidden outputs.
 
output-and = make-neuron(
  table: input-name :: String, weight :: Number
    row: "h1",  50
    row: "h2",  50
  end,
  -75,
  "sigmoid")
 
output-layer = [list: output-and]
 
xor-net = [list: hidden-layer, output-layer]
 
 
# The dataset we'd train on once Unit 7 lands:
 
xor-data = table: x1 :: Number, x2 :: Number, y :: Number
  row: 0, 0, 0
  row: 0, 1, 1
  row: 1, 0, 1
  row: 1, 1, 0
end
 
 
# Confirm the forward pass.  Each call returns a one-element list
# (one output neuron), so we take `.first` to compare it to the target.
 
check "XOR forward pass":
  run(xor-net, [list: 0, 0]).first is-roughly 0
  run(xor-net, [list: 0, 1]).first is-roughly 1
  run(xor-net, [list: 1, 0]).first is-roughly 1
  run(xor-net, [list: 1, 1]).first is-roughly 0
end