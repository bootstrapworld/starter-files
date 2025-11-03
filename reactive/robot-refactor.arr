use context starter2024

# Program to draw an emoji image 

base = circle(50, "solid", "yellow")
eye = circle(9, "solid", "blue")

# create pair of eyes, using a square as a spacer
eye-bar = 
  beside(eye,
    beside(square(12, "solid", "yellow"), 
      eye))
mouth = ellipse(30, 15, "solid", "red")

# create a 3-pixel border for the base
border = circle(53, "solid", "black")
eye-face-spacer = rectangle(30, 15, "solid", "yellow")
eyes-and-mouth = above(eye-bar, above(eye-face-spacer, mouth))

the-face = overlay(eyes-and-mouth, base)

emoji = overlay(the-face, border)
emoji


