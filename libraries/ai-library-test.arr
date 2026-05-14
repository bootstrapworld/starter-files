use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/libraries", "ai-library.arr")

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
  initial-loss = dataset-loss(init-net,    xor-data, [list: "x1", "x2"], "y")
  final-loss   = dataset-loss(xor-trained-net, xor-data, [list: "x1", "x2"], "y")
  (final-loss < initial-loss) is true
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