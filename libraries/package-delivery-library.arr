use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "core.arr")

# The DeliveryState is two numbers: an x-coordinate and a y-coordinate
data DeliveryState:
  | delivery(
      x :: Number,
      y :: Number)
end


# next-position :: Number, Number -> DeliveryState
## Given 2 numbers, make a DeliveryState by adding 5 to x ## and subtracting 5 from y. 

examples:
  next-position(60, 300) is delivery(60, 300 - 5)
  
  next-position(250, 97) is delivery(250, 97 - 5)
end

fun next-position(x, y):
  delivery(x, y - 5)
end








































##########################################################################
## Do not change anything below this line!

START = delivery(130, 420)

DRONE = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/delivery-drone.png")
PACKAGE = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/delivery-package.png")
BACKGROUND = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/delivery-town.png")

# make-update :: DeliveryState -> DeliveryState
fun make-update(fall):
  lam(d):
    var result = fall(d.x, d.y)
    if is-DeliveryState(result): result
    else: delivery(d.x, result)
    end
  end
end

# draw-state :: DeliveryState -> Image
fun draw-state(d):
  if lands-safely(d): 
    put-image(DRONE, 130, 420, 
      put-image(text("Delivered!", 50, "lightgreen"), 320, 240,
        put-image(PACKAGE, d.x, d.y, BACKGROUND)))
  else if hits-house(d): 
    put-image(DRONE, 130, 420, 
      put-image(text("Not in delivery zone!", 50, "red"), 320, 240,
        put-image(PACKAGE, d.x, d.y, BACKGROUND)))
  else if hits-road(d): 
    put-image(DRONE, 130, 420, 
      put-image(text("Not in delivery zone!", 50, "red"), 320, 240,
        put-image(PACKAGE, d.x, d.y, BACKGROUND)))
  else: 
    put-image(DRONE, 130, 420,
      put-image(PACKAGE, d.x, d.y, BACKGROUND))
  end
end

# lands-safely :: DeliveryState -> Boolean
fun lands-safely(d): (d.y < 110) and ((d.x > 300) and (d.x < 575)) end
# hits-house :: DeliveryState -> Boolean
fun hits-house(d): (d.y < 300) and (d.x > 575) end
# hits-road :: DeliveryState -> Boolean
fun hits-road(d): (d.y < 100) and (d.x < 300) end
# done-falling :: DeliveryState -> Boolean
fun done-falling(d): (lands-safely(d) or hits-house(d) or hits-road(d)) end


fun animation(updating-function):
  r = reactor:
    init: START,
    on-tick: make-update(updating-function),
    to-draw: draw-state,
    stop-when: done-falling
  end
  r.interact()
end

# Start the animation
animation(next-position)