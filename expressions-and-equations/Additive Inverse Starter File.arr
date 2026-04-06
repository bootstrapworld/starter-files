use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations", "../libraries/core.arr")

### Explore the `invert` Function with these images

flower = overlay(radial-star(21, 12, 160, "solid", "white"),circle(160, "solid", "black"))

flag = translate(rotate(90, triangle(200, "solid", "white")), 215, 100, rectangle(300, 200,"solid", "black")) 

cat  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/cat.png")


### ARE THEY INVERSES?
# Explore the `blend-images` function with these pairs of images

#blend-image(flower, invert(flower))

butterfly  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/butterfly.png")
butterfly2 = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/butterfly2.png")
# beside(butterfly, butterfly2)

tractor  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/tractor.png")
tractor2  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/tractor2.png")
# beside(tractor tractor2)

moon = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/moon.png")
moon2 = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/moon2.png")

imageA = put-image(circle(40, "solid", "white"), 110, 50,rectangle(200,100,"solid","black"))
imageB = put-image(circle(40, "solid", "black"), 150, 50,rectangle(200,100,"solid","white"))
# beside(imageA, imageB)

imageC = overlay(radial-star(10, 30, 60, "solid", "dark-grey"), circle(60, "solid", "white"))  
imageD = overlay(radial-star(10, 30, 60, "solid", "light-grey"), circle(60, "solid", "black"))
# beside(imageC, imageD)

### What about Color Images?!

blue-square = square(100, "solid", "blue")

purple-triangle = triangle(100, "solid", "purple")

red-star = star(100, "solid","red")

brown-circle = circle(100, "solid", "brown")

dog = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/puppy.png")

dove  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/dove.png")
dove2 = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/dove2.png")