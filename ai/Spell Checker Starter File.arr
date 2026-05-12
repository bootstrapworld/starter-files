use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/spell-checker-library.arr")

# This file has several dictionaries defined, all of different sizes:
# `WORDS-XS` - 100 5-letter words
# `WORDS-S`  - 5,000 most-common words
# `WORDS-M`  - 10,000 most-common words
# `WORDS-L`  - 50,000 most-common words

# You can access the dictionaries spreadsheet by visiting: https://docs.google.com/spreadsheets/d/13vL8Tg4lJ09s9GJwTKTZ9Ne1b6wDa92nj8RUPwgNfBQ

# We've also created some special functions for you to explore:

# Find all spellings that can be reached by substituting a single letter (1 edit)
# subs("hello")

# Find all spellings that can be reached by swapping adjacent letters (1 edit)
# swaps("hello")

# Find all spellings that can be reached by inserting a single letter (1 edit)
# insertions("hello")

# Find all spellings that can be reached by deleting a single letter (1 edit)
# deletions("hello")


# You can combine these functions to generate spellings that are more than 1 edit away
# swaps(swaps("hello"))
# deletions(subs(swaps("hello")))

# Only show words produced by the function that are found in the specified dictionary 
# only-real(subs("hello"), WORDS-L)


# SPELL-CHECKING
# The function alt-words combines all of the tools above, and more!
# - you can search for words that are as many edits away as you like
# - in addition to swapping and subbing, it will also ADD a letter to find alternatives
# For example:
# alt-words("crosswrd", WORDS-L, 2)