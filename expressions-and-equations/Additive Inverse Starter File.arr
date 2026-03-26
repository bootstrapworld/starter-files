use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations", "../libraries/core.arr")

butterfly  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/butterfly.png")
butterfly2 = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/butterfly2.png")

cat  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/cat.png")
cat2 = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/cat2.png")

dove  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/dove.png")
dove2 = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/dove2.png")

tractor  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/tractor.png")
tractor2 = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/tractor2.png")

imageA = put-image(circle(20, "solid", "white"), 55, 25,rectangle(100,50,"solid","black"))
imageB = put-image(circle(20, "solid", "black"), 75, 25,rectangle(100,50,"solid","white"))

imageC = overlay(radial-star(10, 30, 60, "solid", "dark-grey"), circle(60, "solid", "white"))  
imageD = overlay(radial-star(10, 30, 60, "solid", "light-grey"), circle(60, "solid", "black"))
