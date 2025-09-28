use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/projects/flags", "../../libraries/core.arr")

china = 
  translate(
    rotate(40,star(15,"solid","yellow")),
    120, 175,
    translate(
      rotate(80,star(15,"solid","yellow")),
      140, 150,
      translate(
        rotate(60,star(15,"solid","yellow")),
        140, 120,
        translate(
          rotate(40,star(15,"solid","yellow")),
          120, 90,
          translate(scale(3,star(15,"solid","yellow")),
            60, 140,
            rectangle(300, 200, "solid", "red"))))))


