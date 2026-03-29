use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core/", "../libraries/ai-library.arr")

########################################################################
# Some examples of models, and how to use them

########################################################################
# Load the spreadsheet and define our tables
data-sheet = load-spreadsheet(
  "https://docs.google.com/spreadsheets/d/1e_3op5DNDUOAjInXtlrzQ0fKZSuASd65E9-VEjNyteo/")

image-corpus = make-model(transform-column(
    load-table: ID, DOC, RATING, TAGS
      source: data-sheet.sheet-by-name("Images", true)
    end,
    "DOC",
    image-url))

mystery-image = image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/mystery.png")

poem-corpus = make-model(load-table: ID, DOC, RATING, TAGS
    source: data-sheet.sheet-by-name("Poems", true)
  end)

mystery-poem = "The sun is big, but the sea is all"

song-corpus = make-model(load-table: ID, DOC, RATING, TAGS
    source: data-sheet.sheet-by-name("Songs", true)
  end)

mystery-song = "👏 👏 🫰 🫰 👏 🫰 👏 🫰 🫰 🫰 🫰 🫰 🫰 🫰 👏 👏 🫰"


text-corpus = make-model(load-table: ID, DOC, RATING, TAGS
    source: data-sheet.sheet-by-name("Text", true)
  end)

# from https://en.wikipedia.org/wiki/Okapi
mystery-text = "The okapi is classified under the family Giraffidae, along with its closest extant relative, the giraffe. Its distinguishing characteristics are its long neck, and large, flexible ears. Male okapis have horn-like protuberances called ossicones. "


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
      add-luminance(
        add-entropy(
          shrink-images(image-corpus)))),
    "COLOR-NAMES")

# now add a new image, and watch the model regenerate itself with all the same cols!
# image-model.add-doc("test", mystery-image, "dislike", "")

# search for images tagged with "sun" (or similar)
#search-by-tag(image-model, "sun")

# find images closest to the liked images
loved-images    = likes(image-model)
loathed-images  = dislikes(image-model)
img-preference  = build-centroid(loved-images,   "👍")
img-aversion    = build-centroid(loathed-images, "👎")

# find the distance between each row and the provided row
match-row(image-model, img-preference)
#match-row(image-model, img-aversion)

# find images closest to the liked images AND
#     farthest away from the disliked ones
recommend(image-model)