use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/projects", "../libraries/core.arr")

warm-outfit = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/clothing-warm.png")
cool-outfit = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/clothing-cool.png")
cold-outfit = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/clothing-cold.png")
subzero-outfit = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/reactive/images/clothing-subzero.png")


examples:
  wear(81) is warm-outfit
  wear(55) is cool-outfit
  wear(25) is cold-outfit
  wear(-10) is subzero-outfit
end

# Wear : Number -> Image
# Consumes a temperature, produces an image of what to wear based on the temp
fun wear(temp):
  if temp >= 70: warm-outfit
  else if (temp < 70) and (temp >= 50): cool-outfit
  else if (temp < 50) and (temp >= 20): cold-outfit
  else: subzero-outfit
  end
end
