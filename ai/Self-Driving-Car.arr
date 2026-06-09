use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/self-driving-car-library.arr")

# This file includes three functions: 
# In both training functions, the Number is the *animation speed*. Higher = Faster!

#  start a "Bird's Eye View" driving simulator (looking down from above), to train your model
#  train-bev :: Number -> Table

#  start a "Point of View" driving simulator (looking through the windshield), to train your model
#  train-pov :: Number -> Table

#  use a model to drive the car
#  drive :: Driving-Function -> Table

# training-data is a predefined table of high-quality training data


#######################################################################
# Model
fun c-predictor(curve): (...  * curve ) + ... end

# Trained Models from curve, skew, offset, speed and steering-angle
# regression-model-code(training-data, [list: "curve"], "steering-angle")
