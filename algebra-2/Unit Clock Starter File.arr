use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/algebra-2", "../libraries/core.arr")
include url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/algebra-2", "../libraries/unit-clock-library.arr")

# the start-clock function will draw a unit clock, and plot the 
# length of A and B over time.

# speed of the animation 
# faster = more frames/sec
frames-per-second = 5

# divide the circle into "slices"
# For example, a clock would have 12 hours
num-slices = 12  

# direction of rotation
# true = clockwise, false = counter-clockwise
is-cw = true

# where should the first label be? (in "hours o'clock")
# For example, Top = 12, Right = 3, Southwest = 7.5
start = 12

# a sample function, which is just the horizontal line f(x) = 0.5
fun f(x): 0.5 end

# start the clock animation!
start-clock(frames-per-second, num-slices, is-cw, start)

