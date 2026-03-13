use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/expressions-and-equations", "../libraries/core.arr")

#Question 1 & 2
ImageA = text("Azara", 150, "yellow")
A1 = flip-vertical(ImageA)
A2 = rotate(90, ImageA)
A3 = flip-vertical(flip-horizontal(ImageA))
A4 = rotate(180, ImageA)

#Questions 3 and 4:
B1 = rectangle(20, 80, "solid", "blue")
B2 = rectangle(80, 20, "solid", "blue")
B3 = rotate(90, B2)

#Questions 5 and 6:
C1 = square(40, "solid", "deeppink") 
C2 = rectangle(40, 40, "solid", "deeppink")
C3 = square(20 * 20, "solid", "deeppink")

#Question 7 and 8:
D1 = radial-star(6, 20, 50, "solid", "red") 
D2 = radial-star(20, 6, 50, "solid", "red")
D3 = radial-star(3 + 3, 4 * 5, 50, "solid", "red")

#Question 9 and 10:
E1 = circle(60, "outline", "tomato") 
E2 = ellipse(60, 60, "outline", "tomato")
E3 = ellipse(100, 100, "outline", "tomato")

#Question 11 and 12:
F1 = isosceles-triangle(100, 90, "solid", "black")
F2 = right-triangle(100, 100, "solid", "black")
F3 = rotate(135, F1)
F4 = rotate(135, F2)
