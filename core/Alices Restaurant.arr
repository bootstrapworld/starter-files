use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr")

# cost :: String -> Number
# given a menu item, produce the cost of that menu item
fun cost(item):
  if (item == "hamburger"):        6.00
  else if (item == "onion rings"): 3.50
  else if (item == "fried tofu"):  5.25
  else if (item == "pie"):         2.25
  else: "That's not on the menu!"
  end
end

# sales-tax :: Number -> Number
# consumes the item and produces the cost of that
# item, plus a 5% sales tax
examples:
  sales-tax("hamburger") is cost("hamburger") * 1.05
  sales-tax("pie")       is cost("pie"      ) * 1.05
end
fun sales-tax(item):
  cost(item) * 1.05
end

# 1) Click "Run" and try using cost in the interactions area!
# for example, cost("hamburger") should evaluate to 6.

# 2) Once you've experimented in the interactions area, try
# using the "sales-tax" function with some inputs. What happens?
