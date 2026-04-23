use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/spell-checker-library.arr")

# This file has several dictionaries defined, all of different sizes:
# `WORDS-XS` - 100 words
# `WORDS-S`  - 500 words
# `WORDS-M`  - 1000 words
# `WORDS-L`  - 20000 words

# You can access the dictionaries spreadsheet by visiting: https://docs.google.com/spreadsheets/d/13vL8Tg4lJ09s9GJwTKTZ9Ne1b6wDa92nj8RUPwgNfBQ


# To look for alternative words based on a spelling, use the function `alt-words`:

# alt-words :: String, Dictionary, Number -> Table
# Consumes a word, a dictionary, and the maximum edit distance N
# produces a table of alternative words that are N or less edits away

# Here's one example, finding all words that are 1 or 2 edits away
# from "maple" in the XS dictionary
maple-alts = alt-words("maple", WORDS-XS, 2)