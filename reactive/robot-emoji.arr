use context starter2024

##############################
### Robot Emoji by Rebecca ###
##############################

face = put-image(overlay(circle(15, "solid", "white"),
    circle(20, "solid", "steel-blue")), 50, 100,
  put-image(overlay(circle(15, "solid", "white"),
      circle(20, "solid", "steel-blue")), 130, 100,
overlay(triangle(40, "solid", "red"), 
  overlay(overlay(square(150, "solid", "light-sky-blue"),
      square(160, "solid", "steel-blue")),
        rectangle(180, 50, "solid", "red")))))


grill-mouth = put-image(rectangle(7, 25, "solid", "black"), 20, 18,
  put-image(rectangle(7, 25, "solid", "black"), 70, 18, 
    overlay(rectangle(7, 25, "solid", "black"),
      overlay(ellipse(80, 25, "solid", "white"),
        ellipse(90, 35, "solid", "black")))))


robot-emoji = put-image(grill-mouth, 90, 30, face)

robot-emoji

############################
### Robot Emoji by Emily ###
############################

# A single eyeball
eye = overlay(circle(15, "solid", "white"),
  circle(20, "solid", "steel-blue"))

# Putting eyes and nose onto robot's head
head = 
  overlay(triangle(40, "solid", "red"), 
  overlay(
    overlay(
      square(150, "solid", "light-sky-blue"),
      square(160, "solid", "steel-blue")),
    rectangle(180, 50, "solid", "red")))

# Robot's mouth
mouth = 
  put-image(rectangle(7, 25, "solid", "black"), 20, 18,
  put-image(rectangle(7, 25, "solid", "black"), 70, 18, 
    overlay(
        rectangle(7, 25, "solid", "black"),
      overlay(
          ellipse(80, 25, "solid", "white"),
          ellipse(90, 35, "solid", "black")))))


# Full-sized robot head
robot = 
  put-image(mouth, 90, 30, 
    put-image(eye, 50, 100,
      put-image(eye, 130, 100,
        head)))

# Emoji-sized robot head
emoji = scale(0.4, robot)

robot
