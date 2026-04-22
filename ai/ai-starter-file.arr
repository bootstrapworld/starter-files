use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")

########################################################################
# Some examples of models, and how to use them

########################################################################
# Load the spreadsheet and define our tables
data-sheet = load-spreadsheet(
  "https://docs.google.com/spreadsheets/d/1e_3op5DNDUOAjInXtlrzQ0fKZSuASd65E9-VEjNyteo/")

image-corpus = transform-column(
    load-table: ID, DOC, RATING, TAGS
      source: data-sheet.sheet-by-name("Images", true)
    end,
    "DOC",
    image-url)

mystery-image = image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/mystery.png")

poem-corpus = load-table: ID, DOC, RATING, TAGS
    source: data-sheet.sheet-by-name("Poems", true)
  end

mystery-poem = "The sun is big, but the sea is all"

song-corpus = load-table: ID, DOC, RATING, TAGS
    source: data-sheet.sheet-by-name("Songs", true)
  end

mystery-song = "👏 👏 🫰 🫰 👏 🫰 👏 🫰 🫰 🫰 🫰 🫰 🫰 🫰 👏 👏 🫰"


text-corpus = load-table: ID, DOC, RATING, TAGS
    source: data-sheet.sheet-by-name("Text", true)
  end

####################################################################
# 1) Choose one of the corpuses above, and look at it in the
# interactions area. What you notice? 


###################################################################
# 2) Come up with 10 different ways to compute a number from your 
# corpus. For example, "count all the blue pixels in each image"



###################################################################
# 3) We've provided a number of different helper functions, which
# compute all kinds of numbers. They've been used to compute the
# models below. Find the model for your corpus, and look at it in the
# interactions area. What you notice? What do you wonder?

# text can be normalized with or without stop-word removal
normed-poems = add-cleaned(poem-corpus, true)
normed-text  = add-cleaned(text-corpus, true)

# create some bag-of-word columns, using the normalized text
# the song corpus is normalized by default, since it's just emoji
song-model  = add-bag-cols(song-corpus, "DOC")
poem-model  = add-bag-cols(normed-poems, "DOC")
text-model  = add-bag-cols(add-grade(normed-text, "CLEANED"), "DOC")

# shrink the OG images for performance - how small before losing accuracy?
# then add all the fun columns, and a BOW set for pixels
image-model = 
  add-bag-cols(
    add-color-names(
        add-symmetry-v(
          add-entropy(
          add-luminance(image-corpus)))), 
    "color-names")


###################################################################
# 3) Make some visualizations of your chosen corpus. Are the columns
# all evenly distributed, or are there clumps? Outliers?

# example: 
# scatter-plot(image-model, "ID", "entropy", "luminence")
# box-plot(song-model, "🫰")
# pie-chart(text-model)

###################################################################
# 4) Finding rows

# you can use row-n(model, index) to access any row from a model
# define a row for your MOST favorite document in your chosen corpus
most-fav = row-n(image-model, 3)

# define a row for a document in the corpus that is SIMILAR to your favorite
almost-fav = row-n(image-model, 3)

# define a row for your LEAST favorite document in your chosen corpus
least-fav = row-n(image-model, 1)


###################################################################
# 4) How can we measure the similarity of two documents?
# we know that almost-fav is "CLOSER" to most-fav than it is to least-fav
# but how do we measure "closeness" or "similarity"?

# we can check to see if two documents are EXACTLY the same (0 or 1)
simple-similarity(most-fav, most-fav)
simple-similarity(most-fav, almost-fav)
simple-similarity(least-fav, almost-fav)

# we can check to see if their BOWs are the same (0 - 1)
bag-similarity(most-fav, most-fav)
bag-similarity(most-fav, almost-fav)
bag-similarity(least-fav, almost-fav)

# we can measure the angle, taking every column into account (90 - 0)
angle-similarity(most-fav, most-fav)
angle-similarity(most-fav, almost-fav)
angle-similarity(least-fav, almost-fav)

# but it's weird to have 0 mean "most" similar, and it was nice
# to have everything rated between zero and one! We can take the 
# cosine of the angle to get us back to (0 - 1)
cosine-similarity(most-fav, most-fav)
cosine-similarity(most-fav, almost-fav)
cosine-similarity(least-fav, almost-fav)


###################################################################
# 4) Make some visualizations of your chosen corpus. Are the columns
# You can also extract rated documents from your corpus, creating
# a separate corpus for liked and disliked documents. Compare some 
# of your visualizations for liked and disliked documents: do you
# notice any differences? For example, are liked images a lot more
# blue than loathed ones?
loved-images    = likes(image-model)
loathed-images  = dislikes(image-model)


###################################################################
# 5) You can make centroids for any corpus, which show you the 
# "average value" across every parameter. How do you think the 
# centroid for liked songs will differ from the centroid for
# loathed ones?

loved-centroid  = build-centroid(loved-images,   "👍")
loathed-centroid= build-centroid(loathed-images, "👎")

# extract the 0th row from each centroid.
loved-image-row   = row-n(loved-images, 0)
loathed-image-row = row-n(loathed-images, 0)


###################################################################
# 6) How do we check to see if any two documents are similar?
# 



# now add a new image, and watch the model regenerate itself with all the same cols!
# image-model.add-doc("test", mystery-image, "dislike", "")

# search for images tagged with "sun" (or similar)
#search-by-tag(image-model, "sun")

# find images closest to the liked images

# find the distance between each row and the provided row
#match-row(image-model, img-preference)
#match-row(image-model, img-aversion)

# find images closest to the liked images AND
#     farthest away from the disliked ones
#recommend(image-model)