use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

data Cake:
  | cake(
      flavor      :: String,
      layers      :: Number,
      is-iceCream :: Boolean)
end


birthday-cake = cake("Vanilla", 4, true)
chocolate-cake = cake("Chocolate", 5, false)
strawberry-cake = cake("Strawberry", 2, true)
red-velvet-cake = cake("Red Velvet", 2, false)

#####################################
# taller-than : Cake Cake -> Boolean
#



#####################################
# will-melt : Cake, Number -> Boolean
#