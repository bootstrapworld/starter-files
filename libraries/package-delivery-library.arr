provide *

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




r = reactor:
  init: START,
  on-tick: make-update(next-position),
  to-draw: draw-state,
  stop-when: done-falling
end

# Start the animation
r.interact()
