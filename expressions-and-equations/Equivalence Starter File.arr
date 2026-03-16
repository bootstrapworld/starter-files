use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations", "../libraries/core.arr")

#Question 1 and 2
ImageA = text("Azara", 150, "yellow")
A1 = flip-vertical(ImageA)
A2 = rotate(90, ImageA)
A3 = flip-vertical(flip-horizontal(ImageA))
A4 = rotate(180, ImageA)

#Question 3:
B1 = circle(60, "outline", "tomato") 
B2 = ellipse(60, 60, "outline", "tomato")

#Question 4:
C1 = square(40, "solid", "deeppink") 
C2 = rectangle(40, 40, "solid", "deeppink")
C3 = square(20 * 20, "solid", "deeppink")

#Question 5:
D1 = rectangle(48, 72, "solid", "blue")
D2 = rectangle(72, 48, "solid", "blue")
D3 = scale(8, rectangle(6, 9, "solid", "blue"))
D4 = rotate(90, B1)

#Question 6:
E1 = radial-star(6, 20, 50, "solid", "red") 
E2 = radial-star(20, 6, 50, "solid", "red")
E3 = radial-star(3 + 3, 4 * 5, 50, "solid", "red")

#Question 7:
F1 = isosceles-triangle(100, 90, "solid", "black")
F2 = right-triangle(100, 100, "solid", "black")
F3 = rotate(135, F1)
F4 = rotate(135, F2)
