use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/core", "../libraries/core.arr")

# CONTRACT
# gt :: Number -> Image

examples:
  gt(10) is triangle(10, "solid", "green")
  gt(20) is triangle(20, "solid", "green")
  gt(30) is triangle(30, "solid", "green")
  gt(40) is triangle(40, "solid", "green")
  gt(50) is triangle(50, "solid", "green")
end

fun gt(size): triangle(size, "solid", "green") end