use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations", "../libraries/core.arr")

red-star       =  star(20, "solid", "red")
aqua-star      =  star(50, "solid", "aqua")
orange-dot     =  circle(30, "solid", "orange")
purple-square  =  square(100, "solid", "purple")
white-circle   =  circle(30, "solid", "white")
gold-rectangle =  rectangle(120, 60, "solid", "yellow")
blue-ellipse   =  ellipse(60, 30, "solid", "blue")
bootstrap      =  text("Bootstrap", 50, "green")

dog = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/puppy.png")
cat  = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations/images/cat.png")

imageA = put-image(circle(20, "solid", "white"), 55, 25,rectangle(100,50,"solid","black"))
imageB = put-image(circle(20, "solid", "black"), 75, 25,rectangle(100,50,"solid","white"))
# beside(imageA, imageB)

hello = text("hello", 40, "red") 