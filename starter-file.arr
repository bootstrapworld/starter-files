use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "library.arr")

background = rectangle(300, 200, "outline", "black")
rrectangle = rectangle(300, 200/5, "solid", "red")
btriangle = rotate(30, triangle(200, "solid", "blue"))
wstar = star(45, "solid", "white")

puerto-rico =
  put-image(wstar, 65, 100,
    put-image(btriangle, 85, 100,
      put-image(rrectangle, 150, 20,
        put-image(rrectangle, 150, 100,
          put-image(rrectangle, 150, 180,
            background)))))