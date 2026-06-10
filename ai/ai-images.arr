use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")

# define some simple images
black-sq   = square(10, "solid", "black")
white-sq   = square(10, "solid", "white")
red-sq     = square(10, "solid", "red")
green-t    = triangle(15, "solid", "green")
big-red-sq = square(100, "solid", "red")
half-and-half = beside(white-sq, black-sq)
red-blue-tile = overlay(square(4, "solid", "blue"), square(10, "solid", "red"))

# pixels -> model
pixel = image-to-color-list(red-blue-tile)
pixel-dominant-rgb = dominant-rgb-colors(red-blue-tile)

# import some images - you can change these to whatever images you find on the web!
lesson-folder = "https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai/mountain-imgs/"
img1 = image-url(lesson-folder + "adirondacks.png")
img2 = image-url(lesson-folder + "arizona-mountains.png")
img3 = image-url(lesson-folder + "bear-lake.png")
img4 = image-url(lesson-folder + "grassy-mountains.png")
img5 = image-url(lesson-folder + "nz-mountains.png")
img6 = image-url(lesson-folder + "snowy-mountains.png")
img7 = image-url(lesson-folder + "sunny-grass-mountains.png")
img8 = image-url(lesson-folder + "sunrise-mountains.png")
img9 = image-url(lesson-folder + "sunset-mountains.png")

mountains =   image-url(lesson-folder + "all-mountains.webp")

# define the image table
image-corpus = 
  table: ID,       DOC,              LIKED, DISLIKED, TAGS
    row: "day1",   scale(1/2, img1), false,   false,  ""
    row: "day2",   scale(1/2, img2), true,    false,  ""
    row: "day3",   scale(1/2, img3), false,   false,  ""
    row: "grass1", scale(1/2, img4), false,   false,  ""
    row: "snow1",  scale(1/2, img5), false,   false,  ""
    row: "snow2",  scale(1/2, img6), false,   false,  "water"
    row: "grass2", scale(1/2, img7), false,   false,  ""
    row: "sun1",   scale(1/2, img8), false,   false,  ""
    row: "sun2",   scale(1/2, img9), false,   false,  ""
    row: "pixel",  red-blue-tile,    false,   true,   ""
    row: "red1",   red-sq,           false,   true,   ""
    row: "red2",   big-red-sq,       false,   true,   ""
  end

# using the "DOC" column to compute DOMINANT-RGB-COLORS, SYMMETRY, LUMINANCE, etc. 
# and add columns to our image-corpus
model-with-color-names = decorate-image-table(image-corpus, "DOC")

# Use a Bag-of-Words summary to replace our DOMINANT-RGB-COLORS string with columns that count each word
model = add-bag-cols(model-with-color-names, "DOMINANT-RGB-COLORS")

# given a Row, produce an image that's one-half the size
fun thumbnail(r): 
  scale(1/2, r["DOC"])
end