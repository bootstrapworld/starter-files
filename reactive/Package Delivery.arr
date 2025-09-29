use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

include url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive", "../libraries/package-delivery-library.arr")

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

