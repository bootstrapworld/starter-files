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
images = table: ID, doc, rating, tags
  row: "0", img1, "", ""
  row: "1", img2, "", ""
  row: "2", img3, "", ""
  row: "3", img4, "", ""
  row: "4", img5, "", ""
  row: "5", img6, "", ""
  row: "6", img7, "", ""
  row: "7", img8, "", ""
  row: "8", img9, "", ""
end

# given an Image, make it half the size
fun shrink(img): 
  scale(1/2, img) 
end

# shrink every image in image-table, and make a new table
small-images = transform-column(images, "doc", shrink)
decorated = decorate-image-table(small-images, "doc")

# Four rows where the sun is visible
sun1 = row-n(decorated, 0)
sun2 = row-n(decorated, 6)
sun3 = row-n(decorated, 7)
sun4 = row-n(decorated, 8)


# given a Row, produce an image with width=80
fun doc-thumbnail(r): 
  factor = 80 / image-width(r["doc"])
  scale(factor, r["doc"])
end
