use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")
# import some images - you can change these to whatever images you find on the web!
lesson-folder = "https://www.bootstrapworld.org/materials/fall2026/en-us/lessons/measuring-similarity/mountains/"
img1 = image-url(lesson-folder + "adirondacks.png")
img2 = image-url(lesson-folder + "arizona-mountains.png")
img3 = image-url(lesson-folder + "bear-lake.png")
img4 = image-url(lesson-folder + "grassy-mountains.png")
img5 = image-url(lesson-folder + "nz-mountains.png")
img6 = image-url(lesson-folder + "snowy-mountains.png")
img7 = image-url(lesson-folder + "sunny-grass-mountains.png")
img8 = image-url(lesson-folder + "sunrise-mountains.png")
img9 = image-url(lesson-folder + "sunset-mountains.png")

# define the image table, leaving rating and tags empty
images = 
  table: ID,  DOC,  LIKED, DISLIKED, TAGS
    row: "0", img1, false,   false,  ""
    row: "1", img2, false,   false,  ""
    row: "2", img3, false,   false,  ""
    row: "3", img4, false,   false,  ""
    row: "4", img5, false,   false,  ""
    row: "5", img6, false,   false,  ""
    row: "6", img7, false,   false,  ""
    row: "7", img8, false,   false,  ""
    row: "8", img9, false,   false,  ""
  end

# given an Image, make it half the size
fun shrink(img): 
  scale(1/2, img) 
end

# shrink every image in image-table, and make a new table
small-images = transform-column(images, "DOC", shrink)
decorated = decorate-image-table(small-images, "DOC")

# Four rows where the sun is visible
sun1 = row-n(decorated, 0)
sun2 = row-n(decorated, 6)
sun3 = row-n(decorated, 7)
sun4 = row-n(decorated, 8)


# given a Row, produce an image with width=80
fun doc-thumbnail(r): 
  factor = 100 / image-width(r["DOC"])
  scale(factor, r["DOC"])
end
