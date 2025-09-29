use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

data PetState:
  | pet(
      hunger :: Number,
      sleep :: Number,
      happy :: Number)
end

BACKGROUND = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/pet-background.png")
HAPPYCAT   = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/pet-happy.png")
SADCAT     = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/pet-sad.png")

# PetState Instances
FULLPET  = pet(100, 100, 100)

# draw-state:  PetWorld -> Image
fun draw-state(a-pet):
  put-image(text("HUNGER:", 15, "white"),
    35, 450,
    put-image(rectangle(a-pet.hunger * 2, 25, "solid", "green"),
      200, 450,
      put-image(text("SLEEP:", 15, "white"),
        30, 400,
        put-image(rectangle(a-pet.sleep * 2, 25, "solid", "green"),
          200, 400,
          put-image(text("HAPPINESS:", 15, "white"),
            45, 350,
            put-image(rectangle(a-pet.happy * 2, 25, "solid", "green"),
              200, 350,
              put-image(HAPPYCAT, 400, 200, BACKGROUND)))))))
end

pet-react = reactor:
  init: FULLPET,
  to-draw: draw-state
end

pet-react.interact()