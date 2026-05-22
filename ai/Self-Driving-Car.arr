use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/self-driving-car-library.arr")

# This file includes three functions: 
#  train-bev :: Number -> Table
#  starts a driving simulator in "Bird's Eye View", to train your model

#  train-pov :: Number -> Table
#  starts a driving simulator in "Point of View", to train your model

#  drive :: Number, Driving-Function -> Table
#  uses a model to drive the car

# In both cases, the Number is the *animation speed*. Higher = Faster


# If you're having trouble driving, we have some good training data you can use:
#  great-data = get-awesome-data()


# Or you could try to write the model by hand!

# fun predictor(r): (r["curve-sharpness"] * 15) + (r["offset"] * 1) end
# drive(20, predictor)