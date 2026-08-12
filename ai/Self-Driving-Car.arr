use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/self-driving-car-library.arr")

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

# Trained Models from curve, skew, offset, speed and steering-angle
# regression-model-code(training, [list: "curve"], "steering-angle")
