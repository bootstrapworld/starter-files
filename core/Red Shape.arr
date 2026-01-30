use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr")

# red-shape :: String -> Image
# consumes a shape name, and produces a red version of that shape

examples:
  red-shape("circle")    is circle(20, "solid", "red")
  red-shape("triangle")  is triangle(20, "solid", "red")
  red-shape("star")      is star(20, "solid", "red")
  red-shape("rectangle") is rectangle(20, 40, "solid", "red")
end

fun red-shape(shape):  
  if      (shape == "circle")    : circle(20, "solid", "red")
  else if (shape == "triangle")  : triangle(20, "solid", "red")
  else if (shape == "star")      : star(20, "solid", "red")
  else if (shape == "rectangle") : rectangle(20, 40, "solid", "red")
  else: text("Unknown shape name", 20, "red")
  end
end