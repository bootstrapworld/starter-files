use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")

# define some simple images
white-sq   = square(10, "solid", "white")
black-sq   = square(10, "solid", "black")
red-sq     = square(10, "solid", "red")
blue-c     = circle(10, "solid", "blue")
green-t    = triangle(15, "solid", "green")
big-red-sq = square(100, "solid", "red")
half-and-half = beside(white-sq, black-sq)

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

# define the image table, leaving rating and tags empty
images = 
  table: ID,         DOC,       LIKED, DISLIKED, TAGS
    row: "0", scale(1/2, img1), false,   false,  ""
    row: "1", scale(1/2, img2), false,   false,  ""
    row: "2", scale(1/2, img3), false,   false,  ""
    row: "3", scale(1/2, img4), false,   false,  ""
    row: "4", scale(1/2, img5), false,   false,  ""
    row: "5", scale(1/2, img6), false,   false,  ""
    row: "6", scale(1/2, img7), false,   false,  ""
    row: "7", scale(1/2, img8), false,   false,  ""
    row: "8", scale(1/2, img9), false,   false,  ""
    row: "9",       red-sq,     false,   false,  ""
    row: "10",   big-red-sq,    false,   false,  ""
  end

# add columns to our image corpus, computed using the "DOC" column
decorated = decorate-image-table(images, "DOC")

# Use a Bag-of-Words summary to replace our COLOR-NAMES string with columns that count each word
decorated-bag = add-bag-cols(decorated, "COLOR-NAMES")

# Some sample rows
sun1 = row-n(decorated-bag, 0)
sun2 = row-n(decorated-bag, 6)

# given a Row, produce an image that's one-half the size
fun doc-thumbnail(r): 
  scale(1/2, r["DOC"])
end