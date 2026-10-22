use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/main/ai", "../libraries/self-driving-car-library.arr")

# This file includes 3 functions and a predefined table.

# train-bev :: Number -> Table
# starts a "Bird's Eye View" driving simulator (looking down from above)

# train-pov :: Number -> Table
# starts a "Point of View" driving simulator (looking through the windshield)

# drive :: Driving-Function -> Table
# uses a model to drive the car

# training - a predefined table of high-quality training data 


# Note: In the training functions, Number is the *animation speed* in frames per second. Higher = Faster!

#######################################################################

# Define your Model
fun c-predictor(curve): (...  * curve ) + ... end

# NOTES FOR FLANNERY

# d gets the training data, then we look at lr-plots for the three major variables
d = train-bev(20)
lr-plot(d, "id", "curve", "steering-angle")
lr-plot(d, "id", "offset", "steering-angle")
lr-plot(d, "id", "skew", "steering-angle")


# build our regression model for steering-v-curve
curve-fit      = regression-model-fun(d, [list: "curve"], "steering-angle")

# compute the remaining steering-angle variability that is UNexplained by curve-fit
leftover = build-column(d, "steering (curve removed)",
  lam(r): r["steering-angle"] - curve-fit(r) end)

# of the REMAINING variability in steering-angle... 
# how much is explained by offset NOW? (hint: a lot!)
# how much is explained by skew? (hint: not much!)
lr-plot(leftover, "id", "offset", "steering (curve removed)")
lr-plot(leftover, "id", "skew", "steering (curve removed)")

# build our regression model for steering-v-(curve and offset)
curve-offset-fit      = regression-model-fun(d, [list: "curve", "offset"], "steering-angle")

# compute the remaining steering-angle variability that is UNexplained by curve-and-offset-fit
leftover2 = build-column(d, "steering (curve and offset removed)",
  lam(r): r["steering-angle"] - curve-offset-fit(r) end)

# of the remaining variability in steering-angle, how much is explained by skew NOW?
# hint: still not a ton
lr-plot(leftover2, "id", "skew", "steering (curve and offset removed)")

# build our regression model for steering-v-(curve and offset and skew)
curve-offset-skew-fit = regression-model-fun(d, [list: "curve", "offset", "skew"], "steering-angle")


# try driving with curve-fit, curve-offset-fit, and curve-offset-skew-fit!