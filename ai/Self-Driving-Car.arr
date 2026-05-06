use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/self-driving-car-library.arr")

# This file includes two main functions: 
#     train :: Number -> Table
#     drive :: Driving-Function, Number -> Table

# In both cases, the Number is the *animation speed*. Higher = Faster

# Since quality matters, try training the model by driving slowly:
#     d1 = train(10)

# Evaluate d1 to see what data was collected!

# If you're still getting the hang of it, slow down the animation:
#     d2 = train(5)

# You may find it easier to drive the car as if you're looking
# through the windshield, as more of a driver's POV experience:
#     d3 = train-pov(10)

# You can combine data from all three training runs:
#     training-data = stack-tables( [list: d1, d2, d3] )

# Let's train a model:
#   model-a = mr-fun(
#     training-data, 
#     [list: "curve-sharpness", "speed", "offset"], 
#     "steering-angle")

# Now let the model do the driving:
#   drive(model-a, 10)


# Let's train another model, this time making use of "heading-error":
#   model-b = mr-fun(
#     training-data, 
#     [list: "curve-sharpness", "speed", "offset", "heading-error"], 
#     "steering-angle")

# Now let our new model do the driving:
#   drive(model-b, 10)


# You can also load some really good training data as an example:
#     great-data = get-awesome-data()


# You could also try to write the regression function by hand!

# fun predictor(r): (r["curve-sharpness"] * 15) + (r["offset"] * 1) end
# drive(predictor, 20)