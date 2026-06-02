use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/self-driving-car-library.arr")

# This file includes three functions: 
#  train-bev :: Number -> Table
#  starts a driving simulator in "Bird's Eye View", to train your model

#  train-pov :: Number -> Table
#  starts a driving simulator in "Point of View", to train your model

# In both training functions, the Number is the *animation speed*. Higher = Faster!


#  drive :: Driving-Function -> Table
#  uses a model to drive the car

# training-data is a predefined table of high-quality training data


#######################################################################
# Trained Models

fun curve-predictor(curve): (...  * curve ) + ... end

fun offset-predictor(r):  (...  * r["offset"]) + ... end
fun skew-predictor(r):    (...  * r["skew"]  ) + ... end
fun speed-predictor(r):   (...  * r["speed"] ) + ... end