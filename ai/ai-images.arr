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
  row: "1", img1, "", ""
  row: "2", img2, "", ""
  row: "3", img3, "", ""
  row: "4", img4, "", ""
  row: "5", img5, "", ""
  row: "6", img6, "", ""
  row: "7", img7, "", ""
  row: "8", img8, "", ""
  row: "9", img9, "", ""
end

# shrink all the images and make a new image table
fun shrink(img): scale(1/2, img) end
small-images = transform-column(images, "doc", shrink)

# define a new table, with two computed columns
images2 = images