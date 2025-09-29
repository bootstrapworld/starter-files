use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

# a SunsetState is the x-coordinate of the sun
# and the y-coordinate of the sun
data SunsetState:
 | sunset(
     xpos :: Number,
     ypos :: Number)
end

sketchA = sunset(10, 300)

#########################################
# draw-state : SunsetState -> Image
#

#########################################
# next-state-tick : SunsetState -> Image
#

#########################################
# define the reactor