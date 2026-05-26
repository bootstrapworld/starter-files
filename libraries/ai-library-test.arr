use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/libraries", "ai-library.arr")
examples "text-streak":
  text-streak("sun sea sun sun sand", "sun")     is 2
  text-streak("sea sea sea", "sea")              is 3
  text-streak("sand sun sea", "cyan")            is 0
  text-streak("sun sun sand sun sun sun", "sun") is 3
end


_centroid-test = 
  table: ID, DOC, LIKED, DISLIKED, TAGS, x, y  
    row: "a", "", true,   false,   "",   2, 1 
    row: "b", "", true,   true,    "",   4, 5 
  end
examples "add-centroid":
  add-centroid(_centroid-test, "test", [list: "a", "b"]) is
  table: ID, DOC, LIKED, DISLIKED, TAGS, x, y  
    row: "a", "", true,   false,   "",   2, 1 
    row: "b", "", true,   true,    "",   4, 5 
    row: "test CENTROID", "", false, false, "", 3, 3
  end
end

fun find-by-tag(t :: Table, tag :: String): 
  filter(t, {(r): string-contains(r["TAGS"], tag) }) 
end

examples "simple-clustering":
  simple-clustering([list: 10, 2, 8, 1, 9, 3], 2) is [list: {1; 3}, {8; 10}]
  simple-clustering([list: 5, 1, 10], 2) is [list: {1; 5}, {10; 10}]
end

examples "k-means-clustering":
  k-means-clustering([list: 1, 10, 2, 11], 2) is [list: {1; 2}, {10; 11}]
end

examples "get-boundary-threshold":
  get-boundary-thresholds([list: {1; 2}, {10; 12}]) is [list: 6]
  get-boundary-thresholds([list: {1; 2}, {10; 12}, {20; 22}]) is [list: 6, 16]
end

examples "step and sigmoid":
  sigmoid(0)    is-roughly 0.5
  sigmoid(100)  is-roughly 1
  sigmoid(-100) is-roughly 0
  step(0)    is 1
  step(2.5)  is 1
  step(-0.1) is 0
end


examples "apply-activation":
  apply-activation("sigmoid",  0) is-roughly 0.5
  apply-activation("step",    -1) is 0
  apply-activation("step",     1) is 1
end


examples "weighted sum":
  weighted-sum([list: 4, 3],    [list: 0.5, -1.0])    is (4 * 0.5) + (3 * -1.0)
  weighted-sum([list: 1, 1, 1], [list: 0.2, 0.3, 0.5]) is-roughly 1.0
  weighted-sum([list: ],        [list: ])              is 0
end

n1 = make-neuron(
  table: input-name :: String, weight :: Number
    row: "x", 5
  end,
  0,
  "step")
examples "make-neuron":
  neuron-output(n1, [list:  0.5]) is 1     #  5 *  0.5 =  2.5, step => 1
  neuron-output(n1, [list: -1])   is 0     #  5 * -1   = -5,   step => 0
end


good = make-neuron(
  table: input-name :: String, weight :: Number
    row: "x", 1
  end,
  0, "step")
  good-after = perceptron-update(good, [list: 1], 1, 0.5)
examples "perceptron-update":
  neuron-output(good, [list: 1]) is 1
  neuron-output(good-after, [list: 1]) is 1
end


pass-through = make-neuron(
table: input-name :: String, weight :: Number row: "x", 1 end,
  0, "step")
examples "forward-pass":
  # A one-layer, one-neuron "network" that just passes its input along:
  run([list: [list: pass-through]], [list: 1]) is [list: 1]
  # Two such layers stacked: still passes the input along.
  run([list: [list: pass-through], [list: pass-through]], [list: 1]) is [list: 1]
end

n-pos = make-neuron(
table: input-name :: String, weight :: Number row: "x",  1 end,
  0, "step")
n-neg = make-neuron(
table: input-name :: String, weight :: Number row: "x", -1 end,
  0, "step")
examples "layer-output":
  layer-output([list: n-pos, n-neg], [list:  1]) is [list: 1, 0]
  layer-output([list: n-pos, n-neg], [list: -1]) is [list: 0, 1]
  # interesting test!
  # both neurons will fire here
  layer-output([list: n-pos, n-neg], [list: 0]) is [list: 1, 1]
end

examples "squared-error":
  squared-error(0,    0)   is 0
  squared-error(1,    1)   is 0
  squared-error(0.5,  1)   is-roughly 0.25
  squared-error(0,    2)   is 4
  squared-error(2,    0)   is 4    # symmetric in its arguments
end


# A one-neuron network with a huge positive bias outputs ~1 for any input.
always-one = make-neuron(
  table: input-name :: String, weight :: Number
    row: "x", 0
  end,
  100, "sigmoid")
always-one-net = [list: [list: always-one]]
ones-data = table: x :: Number, y :: Number
  row: 0, 1
  row: 1, 1
end
examples "dataset-loss":
  dataset-loss(always-one-net, ones-data, [list: "x"], "y") is-roughly 0
end



tiny = make-neuron(
  table: input-name :: String, weight :: Number
    row: "x", 0.5
  end,
  0, "sigmoid")
tiny-net  = [list: [list: tiny]]
tiny-data = table: x :: Number, y :: Number  row: 1, 1  end
g = numerical-gradient(tiny-net, tiny-data, [list: "x"], "y", 0.001)
examples "numerical-gradient":
  # Sanity check: the gradient has the same shape as the network.
  g.length()       is tiny-net.length()             # same #layers
  g.first.length() is tiny-net.first.length()       # same #neurons
end




# A zero gradient leaves the network unchanged.
n = make-neuron(
table: input-name :: String, weight :: Number row: "x", 0.7 end,
  0.2, "sigmoid")
net = [list: [list: n]]
zero-grad = make-neuron(
table: input-name :: String, weight :: Number row: "x", 0 end,
  0, "sigmoid")
zero-grad-net = [list: [list: zero-grad]]
stepped = apply-gradient(net, zero-grad-net, 1)
examples "apply-gradient":
  stepped.first.first.bias is 0.2
  stepped.first.first.weights.column("weight") is [list: 0.7]
end




# A one-neuron sigmoid network learning y = sigmoid(2x).
# Initial weight 0, bias 0 → initial output 0.5 for every x.
start = make-neuron(
table: input-name :: String, weight :: Number row: "x", 0 end,
  0, "sigmoid")
start-net = [list: [list: start]]
toy-data = table: x :: Number, y :: Number
  row:  2, 0.98
  row:  1, 0.88
  row:  0, 0.5
  row: -1, 0.12
  row: -2, 0.02
end

train-result = train(start-net, toy-data, [list: "x"], "y", 1, 200)
train-initial-loss = dataset-loss(start-net,     toy-data, [list: "x"], "y")
train-final-loss   = dataset-loss(train-result.trained, toy-data, [list: "x"], "y")
examples "train":
  # Training has to drive the loss meaningfully downward.
  (train-final-loss < train-initial-loss) is true
  (train-final-loss < 0.01)               is true
end


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


# ---- Initial network ----
# We pick small, asymmetric starting weights.  If both hidden neurons
# started identical, gradient descent would update them identically
# and they would stay identical forever — the "symmetry problem".

init-h1 = make-neuron(
  table: input-name :: String, weight :: Number
    row: "x1",  0.5
    row: "x2", -0.3
  end,
  0.1, "sigmoid")

init-h2 = make-neuron(
  table: input-name :: String, weight :: Number
    row: "x1", -0.2
    row: "x2",  0.4
  end,
  -0.1, "sigmoid")

init-output = make-neuron(
  table: input-name :: String, weight :: Number
    row: "h1",  0.3
    row: "h2", -0.4
  end,
  0.2, "sigmoid")

init-net = [list: [list: init-h1, init-h2], [list: init-output]]


# ---- Train ----
# Knobs to play with:
#   learning-rate -- bigger steps faster but can overshoot
#   epochs        -- more = lower loss, until it plateaus

LEARNING-RATE = 5
EPOCHS        = 3000

xor-result        = train(init-net, xor-data, [list: "x1", "x2"], "y",
  LEARNING-RATE, EPOCHS)
xor-trained-net   = xor-result.trained
xor-loss-history  = xor-result.loss-history


# ---- Inspect ----
# A convenience for testing predictions on a 2-input network.
fun predict(x1 :: Number, x2 :: Number) -> Number:
  run(xor-trained-net, [list: x1, x2]).first
end


# The trained network should match XOR much more closely than the
# initial one.
check "XOR training reduces loss":
  xor-initial-loss = dataset-loss(init-net,    xor-data, [list: "x1", "x2"], "y")
  xor-final-loss   = dataset-loss(xor-trained-net, xor-data, [list: "x1", "x2"], "y")
  (xor-final-loss < xor-initial-loss) is true
end

# With enough epochs the network produces the right answer on every
# input.  We use a generous 0.1 tolerance because the sigmoid never
# quite reaches 0 or 1.
check "XOR trained predictions":
  fun close(a, b): abs(a - b) < 0.1 end
  predict(0, 0) is%(close) 0
  predict(0, 1) is%(close) 1
  predict(1, 0) is%(close) 1
  predict(1, 1) is%(close) 0
end


# To visualize training, students can plot the loss-history table
# with their usual Pyret chart import:
#
#     include shared-gdrive("Bootstrap", "your-charts-file.arr")
#     line-plot(loss-history, "epoch", "loss")
#
# (Adjust the chart call to whatever Bootstrap's chart API uses.)

# ============================================================
#  iris-2class.arr  —  a single neuron learns to tell two species
#  of iris apart from their petal measurements.
#
#  This is the companion to xor-train.  Where XOR needed a
#  hidden layer (it is NOT linearly separable), setosa-vs-versicolor
#  IS linearly separable from the petal features alone — so a
#  network of ONE neuron is enough.  A good contrast for students:
#  the architecture you need depends on the shape of the data.
#
#  Rows are taken from the classic Iris dataset.  The label column
#  `is-versicolor` is 1 for versicolor and 0 for setosa.
# ============================================================


# ---- The raw data (petal measurements, in centimetres) ----
#
# 8 + 8 rows for training, 2 + 2 rows held out for testing.

iris-train = table: petal-length :: Number, petal-width :: Number, is-versicolor :: Number
  row: 1.4, 0.2, 0     # setosa
  row: 1.5, 0.1, 0
  row: 1.5, 0.2, 0
  row: 1.6, 0.2, 0
  row: 1.4, 0.3, 0
  row: 1.1, 0.1, 0
  row: 1.2, 0.2, 0
  row: 1.5, 0.4, 0
  row: 4.7, 1.4, 1     # versicolor
  row: 4.5, 1.5, 1
  row: 4.9, 1.5, 1
  row: 4.0, 1.3, 1
  row: 4.6, 1.5, 1
  row: 3.3, 1.0, 1
  row: 4.2, 1.5, 1
  row: 3.9, 1.1, 1
end

iris-test = table: petal-length :: Number, petal-width :: Number, is-versicolor :: Number
  row: 1.3, 0.2, 0     # setosa     (not in the training set)
  row: 1.7, 0.3, 0
  row: 4.4, 1.4, 1     # versicolor (not in the training set)
  row: 3.5, 1.0, 1
end


# ---- Normalisation ----
#
# Petal length runs about 1-5 cm; petal width only about 0.1-1.8 cm.
# Left raw, the length feature would push the gradient around just
# because its numbers are bigger.  Dividing each column by a round
# constant pulls both features into roughly the 0-1 range, so they
# pull with comparable strength.
#
# (A real pipeline would compute these scales FROM the data — that's
#  a good extension exercise for students.)

PETAL-LENGTH-SCALE = 5
PETAL-WIDTH-SCALE  = 2

fun normalize-iris(t :: Table) -> Table:
  doc: "Scale the two petal columns into roughly the 0-1 range."
  t.transform-column("petal-length", lam(v): v / PETAL-LENGTH-SCALE end)
    .transform-column("petal-width",  lam(v): v / PETAL-WIDTH-SCALE  end)
end

norm-train = normalize-iris(iris-train)
norm-test  = normalize-iris(iris-test)


# ---- The network: ONE sigmoid neuron with two inputs ----
#
# No hidden layer.  A single neuron is exactly a linear classifier,
# and a linear boundary is all this problem needs.

init-neuron = make-neuron(
  table: input-name :: String, weight :: Number
    row: "petal-length",  0.1
    row: "petal-width",  -0.1
  end,
  0, "sigmoid")

shadow init-net = [list: [list: init-neuron]]


# ---- Train ----

FEATURES = [list: "petal-length", "petal-width"]
LABEL    = "is-versicolor"

shadow LEARNING-RATE = 2
shadow EPOCHS        = 1000

shadow petal-result       = train(init-net, norm-train, FEATURES, LABEL, LEARNING-RATE, EPOCHS)
shadow petal-trained-net  = petal-result.trained
shadow petal-loss-history = petal-result.loss-history


# takes RAW petal measurements, normalises them the same
# way the training data was normalised, runs the network, and
# thresholds the output at 0.5.  Returns 1 (versicolor) or 0 (setosa).

fun classify-petal(petal-length :: Number, petal-width :: Number) -> Number:
  pl = petal-length / PETAL-LENGTH-SCALE
  pw = petal-width  / PETAL-WIDTH-SCALE
  output = run(petal-trained-net, [list: pl, pw]).first
  if output >= 0.5: 1 else: 0 end
end


# ---- Checks ----

check "training reduces loss":
  initial-loss = dataset-loss(init-net,    norm-train, FEATURES, LABEL)
  final-loss   = dataset-loss(petal-trained-net, norm-train, FEATURES, LABEL)
  (final-loss < initial-loss) is true
end

check "classifies the training data correctly":
  classify-petal(1.4, 0.2) is 0    # setosa
  classify-petal(1.1, 0.1) is 0    # setosa
  classify-petal(4.7, 1.4) is 1    # versicolor
  classify-petal(3.3, 1.0) is 1    # versicolor
end

check "generalises to the held-out test data":
  # None of these four rows were seen during training.
  classify-petal(1.3, 0.2) is 0    # setosa
  classify-petal(1.7, 0.3) is 0    # setosa
  classify-petal(4.4, 1.4) is 1    # versicolor
  classify-petal(3.5, 1.0) is 1    # versicolor
  # The test-set loss should also be low — the neuron learned the
  # pattern, it did not just memorise the training rows.
  (dataset-loss(petal-trained-net, norm-test, FEATURES, LABEL) < 0.1) is true
end


# To SEE what happened, students can chart two things with their
# usual Pyret chart import:
#   * loss-history -- "epoch" vs "loss": watch the network learn.
#   * iris-train   -- a scatter of "petal-length" vs "petal-width"
#                     coloured by "is-versicolor": see why a single
#                     straight boundary is enough to separate them.