use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations", "../libraries/core.arr")

cat  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/cat.png")

tractor  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/tractor.png")

dove  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/dove.png")
dove2 = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/dove2.png")

butterfly  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/butterfly.png")
butterfly2 = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/butterfly2.png")

imageA = put-image(circle(20, "solid", "white"), 55, 25,rectangle(100,50,"solid","black"))
imageB = put-image(circle(20, "solid", "black"), 75, 25,rectangle(100,50,"solid","white"))

imageC = overlay(radial-star(10, 30, 60, "solid", "dark-grey"), circle(60, "solid", "white"))  
imageD = overlay(radial-star(10, 30, 60, "solid", "light-grey"), circle(60, "solid", "black"))
