use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "core.arr")

################################################################
# Bootstrap Bag of Words Library, as of Fall 2026

provide *

# Re-export everything from starter2024, except for functions we override
import starter2024 as Starter
include from Starter:
    * hiding(translate, filter, range, sort, sin, cos, tan)
end


# add a DOC to the table
fun add-doc(table, id, doc):
  row = [T.raw-row: {"ID"; id}, {"DOC"; doc}]
  table.empty().add-row(row).stack(table)
end

# columns that should always be ignored
restricted-cols = [list: "ID", "DOC", "RATING", "TAGS"]
fun get-unrestricted-cols(r):
  r.get-column-names().filter({(c): not(member(restricted-cols, c))})
end

# Load your spreadsheet and define your table
data-sheet = load-spreadsheet(
  "https://docs.google.com/spreadsheets/d/1e_3op5DNDUOAjInXtlrzQ0fKZSuASd65E9-VEjNyteo/")

# load the 'animals' sheet as a table
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

# from https://en.wikipedia.org/wiki/Okapi
mystery-text = "The okapi is classified under the family Giraffidae, along with its closest extant relative, the giraffe. Its distinguishing characteristics are its long neck, and large, flexible ears. Male okapis have horn-like protuberances called ossicones. "


##############################################################################################################
# Image Helpers

# doc-to-color-names :: Table -> Table
# Replaces each image with a string of comma-separated color names ("red", "green",
# or "blue") representing the dominant channel of each non-transparent pixel
fun doc-to-color-names(t) -> Table block:
  fun dominant-color(pixel) -> String:
    if (pixel.red >= pixel.green) and (pixel.red >= pixel.blue): "red"
    else if (pixel.green >= pixel.red) and (pixel.green >= pixel.blue): "green"
    else: "blue"
    end
  end
  transform-column(t, "DOC", lam(img): image-to-color-list(img)
        .filter(lam(pixel): pixel.alpha > 0 end)
        .map(dominant-color)
        .join-str(" ")
    end)
end


fun shrink-images(t) -> Table:
  transform-column(t, "DOC", lam(img): scale(0.5, img) end)
end

# For every row, compute luminance of the DOC image
fun add-luminance(t) -> Table:
  build-column(t, "LUMINANCE", lam(r):
      avg-luminance = Stats.mean(image-to-color-list(r["DOC"]).map(luminance))
      num-exact(num-round-to(avg-luminance, 10))
    end)
end

# For every row, compute entropy of the DOC image
fun add-entropy(t) -> Table block:
  # Sum -p*log2(p) over all keys in the frequency table
  fun entropy-sum(keys :: List, freq :: SD.StringDict, total :: Number, acc :: Number) -> Number:
    cases (List) keys:
      | empty => acc
      | link(k, rest) =>
        p = freq.get-value(k) / total
        contribution = p * (num-log(p) / num-log(2))
        entropy-sum(rest, freq, total, acc - contribution)
    end
  end
  build-column(t, "ENTROPY", lam(r):
      # Build a frequency table of grayscale values as a StringDict
      fun build-freq(pixels :: List, acc :: SD.StringDict) -> SD.StringDict:
        cases (List) pixels:
          | empty => acc
          | link(px, rest) =>
            key = num-to-string(color-to-gray(px))
            shadow count = if acc.has-key(key): acc.get-value(key) else: 0 end
            build-freq(rest, acc.set(key, count + 1))
        end
      end
      pixels = image-to-color-list(r["DOC"])
      total = pixels.length()
      freq = build-freq(pixels, [SD.string-dict:])
      entropy = entropy-sum(freq.keys().to-list(), freq, total, 0)
      num-exact(num-round-to(entropy, 10))
    end)
end

# For every row, compute the dominant color of the DOC image
fun add-color(t) -> Table:
  build-column(t, "MAIN-COLOR", lam(r):
      fun pixel-color(p): (p.red * sqr(256)) + (p.green * 256) + p.blue end
      color-encodings = image-to-color-list(r["DOC"]).map(pixel-color)
      num-exact(num-round-to(Stats.mean(color-encodings), 10))
    end)
end
##############################################################################################################
# Text Helpers

fun massage-string(w :: String) -> String block:
  fun is-non-punct(c :: String) -> Boolean block:
    # Code points for 'a' and 'z', used to test if a char is a lowercase ASCII letter
    lower-case-a-cp = string-to-code-point('a')
    lower-case-z-cp = string-to-code-point('z')
    if (c == ' ') or (c == '\n'): true
    else:
      c-cp = string-to-code-point(c)
      (c-cp >= lower-case-a-cp) and (c-cp <= lower-case-z-cp)
    end
  end
  fold(lam(string-a, string-b): string-a + string-b end, '', string-explode(string-to-lower(w)).filter(is-non-punct))
end

# normalize the "DOC" column by:
# 1) massaging the string (lowercase + remove punctuation)
# 2) splitting on spaces
# 3) filtering out any empty strings
fun normalize(t) -> Table block:
  fun is-non-empty-string(w :: String) -> Boolean:  w <> '' end
  transform-column(t, "DOC",
    lam(s): string-split-all(massage-string(string-to-lower(s)), ' ')
        .filter(is-non-empty-string)
        .join-str(' ')
    end)
end

# A standard list of English stop words (common words like "the", "and",
# "a" etc.) that carry little meaning and can be ignored when comparing
# DOCs for similarity. From Fox (1990).
standard-stop-words = [list: "the", "and", "a", "that", "was", "for", "with", "not", "on", "at", "i", "had", "are", "or", "an", "they", "one", "would", "all", "there", "their", "him", "has", "when", "if", "out", "what", "up", "about", "into", "can", "other", "some", "time", "two", "then", "do", "now", "such", "man", "our", "even", "made", "after", "many", "must", "years", "much", "your", "down", "should", "of", "to", "in", "is", "he", "it", "as", "his", "be", "by", "this", "but", "from", "have", "you", "which", "were", "her", "she", "will", "we", "been", "who", "more", "no", "so", "said", "its", "than", "them", "only", "new", "could", "these", "may", "first", "any", "my", "like", "over", "me", "most", "also", "did", "before", "through", "where", "back", "way", "well", "because", "each", "people", "state", "mr", "how", "make", "still", "own", "work", "long", "both", "under", "never", "same", "while", "last", "might", "day", "since", "come", "great", "three", "go", "few", "use", "without", "place", "old", "small", "home", "went", "once", "school", "every", "united", "number", "does", "away", "water", "fact", "though", "enough", "almost", "took", "night", "system", "general", "better", "why", "end", "find", "asked", "going", "knew", "toward", "just", "those", "too", "world", "very", "good", "see", "men", "here", "get", "between", "year", "another", "being", "life", "know", "us", "off", "against", "came", "right", "states", "take", "himself", "during", "again", "around", "however", "mrs", "thought", "part", "high", "upon", "say", "used", "war", "until", "always", "something", "public", "put", "think", "head", "far", "hand", "set", "nothing", "point", "house", "later", "eyes", "next", "program", "give", "white", "room", "social", "young", "present", "order", "second", "possible", "light", "face", "important", "among", "early", "need", "within", "business", "felt", "best", "ever", "least", "got", "mind", "want", "others", "although", "open", "area", "done", "certain", "door", "different", "sense", "help", "perhaps", "group", "side", "several", "let", "national", "given", "rather", "per", "often", "god", "things", "large", "big", "become", "case", "along", "four", "power", "saw", "less", "thing", "today", "interest", "turned", "members", "family", "problem", "kind", "began", "thus", "seemed", "whole", "itself"]

# remove-stop-words filters a list of words, removing
# any that appear in the standard stop words list
fun remove-stop-words(t) -> Table:
  transform-column(t, "DOC",
    lam(s): string-split-all(s, ' ')
        .filter({(w): not(standard-stop-words.member(w))})
        .join-str(' ')
    end)
end


##############################################################################################################
# Song Helpers

fun longest-streak(str :: String, target :: String) -> Number:
  words = string-split-all(str, " ")

  init-state = { current: 0, max-seen: 0 }

  final-stats = for fold(acc from init-state, w from words):
    if w == target:
      new-current = acc.current + 1
      {
        current: new-current,
        max-seen: num-max(new-current, acc.max-seen) }
    else:
      {
        current: 0,
        max-seen: acc.max-seen
      }
    end
  end

  final-stats.max-seen
where:
  longest-streak("sun sea sun sun sand", "sun")     is 2
  longest-streak("sea sea sea", "sea")              is 3
  longest-streak("sand sun sea", "cyan")            is 0
  longest-streak("sun sun sand sun sun sun", "sun") is 3
end

fun longest-snaps(s): longest-streak(s, "🫰") end
fun longest-clap(s):  longest-streak(s, "👏") end
fun longest-stomp(s): longest-streak(s, "🦶") end


##############################################################################################################
# Ratings & Recommendations

# Given a table, recursively build the centroid as a StringDict
# by averaging each non-restricted column. Use exactnum to allow
# for easy comparison
fun build-centroid(t :: Table) -> Row:
  cols = t.column-names().filter({(c): not(member(restricted-cols, c))})
  fun add-col-avgs(shadow cols, acc):
    cases (List) cols:
      | empty => acc
      | link(col, rest) =>
        if cols.member(col) block:
          avg = if t.get-column(col).length() == 0: 0
          else: Stats.mean(t.get-column(col))
          end
          val = num-round-to(avg, 10)
          add-col-avgs(rest, L.link({col; num-exact(val)}, acc))
        else:
          add-col-avgs(rest, acc)
        end
    end
  end
  # compute all the averages in reverse-order (since L.link reverses)
  averages = add-col-avgs(cols.reverse(), [list:])
  restricted = [list: {"ID";"CENTROID"}, {"DOC";""}, {"RATING";""}, {"TAGS";""}]
  T.raw-row.make(raw-array-from-list(L.append(restricted, averages)))
end

_centroid-test = table: x, y row: 2, 1 row: 4, 5 end
examples:
  build-centroid(_centroid-test) is [T.raw-row: {"ID";"CENTROID"},{"DOC";""}, {"RATING";""}, {"TAGS";""},{"x";3},{"y";3}]
end

fun likes(t):    filter(t, {(r): r["RATING"] == "like"    }) end
fun dislikes(t): filter(t, {(r): r["RATING"] == "dislike" }) end
fun unrated(t):  filter(t, {(r): r["RATING"] == "-"       }) end



# Given a table, find the centroids for likes and dislikes,
# if they exist. If neither does, raise an error.
# Otherwise, find the unlabeled row that is MOST similar
# to the like-centroid and the LEAST similar to the dislike one
fun recommend(t) block:
  liked     = likes(t)
  disliked  = dislikes(t)
  not-rated = unrated(t)

  # make sure we have some ratings
  when (liked.length() + disliked.length()) == 0:
    raise("No recommendations could be computed without at least one RATING")
  end

  # compute the centroids
  preference = build-centroid(liked)
  aversion   = build-centroid(disliked)

  # for every unlabeled DOC, compute the similarity from both
  # centroids. Then subtract dislike from like for a general
  # recommendation score, and sort from most-recommended to least
  not-rated
    .build-column("like",       {(r):
      if liked.length() == 0: 0 else: cosine-similarity(preference, r) end })
    .build-column("dislike",    {(r):
      if disliked.length() == 0: 0 else: cosine-similarity(aversion, r) end })
    .build-column("recommend",  {(r): r["like"] - r["dislike"]})
    .order-by("recommend", false)
end


##############################################################################################################
# Bag Of Words Tools

# list-of-words-to-sd converts a list of strings into a StringDict
# mapping each unique word to its frequency count.
# For example, ["a", "b", "a"] -> {"a": 2, "b": 1}
fun list-of-words-to-sd(xx :: List<String>) -> SD.StringDict<Number> block:
  msd = [SD.mutable-string-dict:]
  for each(x from xx):
    old-value = cases(Starter.Option) (msd.get-now(x)):
      | none => 0
      | some(v) => v
    end
    msd.set-now(x, old-value + 1)
  end
  msd.freeze()
end


# add-bag-cols consumes a table containing a "text" column and returns
# an expanded version of that table with one additional column per
# unique word found across all rows. Each new column is named after
# the word it represents, and each cell contains the number of times
# that word appears in that row's text. Rows where the word doesn't
# appear get a count of 0.
#
# For example, given:
#   text
#   ------------
#   "doo be doo"
#   "be bop bop"
#
# ...the result would be:
#   text          | doo | be | bop
#   --------------|-----|----|----|
#   "doo be doo"  |  2  |  1 |  0
#   "be bop bop"  |  0  |  1 |  2
fun convert-to-bag(t :: Table) -> Table block:
  # Step 1: convert each row's text into a normalized word list
  all-word-lists = t.column("DOC").map(lam(s): string-split-all(s, ' ') end)

  # Step 2: collect the union of all unique words across every row
  unique-words = all-word-lists.foldl(
    lam(word-list, acc):
      word-list.foldl(lam(w, shadow acc): acc.add(w) end, acc)
    end,
    Sets.list-to-set([list:]))
    .to-list()

  # Step 3: for each unique word, add a column whose values are the
  # per-row frequency of that word. We recompute the word-frequency
  # dict inside each build-column call since build-column only gives
  # us the row, not the row index.
  unique-words.foldl(
    lam(word, shadow t):
      t.build-column(word, lam(r):
          words = string-split-all(r["DOC"], ' ')
          sd = list-of-words-to-sd(words)
          cases(Starter.Option) sd.get(word):
            | none => 0
            | some(shadow count) => count
          end
        end)
    end,
    t)
  #    .drop("DOC")
end

fun add-col(t :: Table, name :: String, fn):
  build-column(t, name, lam(r): fn(r["DOC"]) end)
end


##############################################################################################################
# Similarity Tools
# All of these methods of comparison produce a numerical value


# dot-product computes the dot product of two word-frequency StringDicts.
# For each word that appears in both dicts, it multiplies the two
# frequencies and sums the results. Words that only appear in one dict
# contribute nothing (implicitly treated as 0 frequency in the other).
fun dot-product(
    sd1 :: SD.StringDict<Number>,
    sd2 :: SD.StringDict<Number>)
  -> Number block:
  var n = 0
  for each(key from sd1.keys-list()) block:
    if sd2.has-key(key):
      n := n + (sd1.get-value(key) * sd2.get-value(key))
    else: false
    end
  end
  n
end


# given a row, convert to a string-dict where cols are keys
# be sure to force all nums to exact, to allow for
# rapid comparison!
fun row-to-dict(cols :: List<String>, r :: Row) -> SD.StringDict<Number>:
  cases (List) cols:
    | empty => [SD.string-dict:]
    | link(col, rest) =>
      row-to-dict(rest, r).set(col, num-exact(r[col]))
  end
end

################################################################
# The library offers three levels of comparison, each operating
# on String inputs directly.
# The four comparison approaches are:
#
# 1. simple-similarity — exact word-for-word match (order matters)
# 2. bag-similarity    — same words in any order (frequency matters)
# 3. cosine-similarity — a continuous score from 0 to 1 measuring
#                        how similar the word frequency vectors are
# 4. angle-similarity  — converts cosine similarity to an angle (0-90°),
#                        where 0° means identical and 90° means nothing
#                        in common.
################################################################

# simple-similarity: true iff the two DOCs are identical
# (same words, same order, same frequency)
fun simple-similarity(r1 :: Row, r2 :: Row) -> Number block:
  cols = r1.get-column-names()
  when not(member(cols, "DOC")):
    raise("Simple similarity requires that all rows have a 'DOC' column")
  end
  if (r1["DOC"] == r2["DOC"]): 1 else: 0 end
end

# bag-similarity: returns 1 the two bags contain the same words
# with the same frequencies (regardless of order). Otherwise 0.
fun bag-similarity(r1 :: Row, r2 :: Row) -> Number block:
  cols = get-unrestricted-cols(r1)
  when cols.length() == 0:
    raise("Bag similarity ignores certain columns (" + restricted-cols.join-str(", ") + "), but no other columns were found")
  end
  sd1 = row-to-dict(cols, r1)
  sd2 = row-to-dict(cols, r2)

  if (sd1 == sd2): 1 else: 0 end
end


# sd-cos-sim: returns a number from 0 to 1 measuring how
# similar the two word-frequency vectors are. 1 = identical bags,
# 0 = no words in common. Uses the standard cosine similarity formula:
#   cos(θ) = (A · B) / (|A| * |B|)
fun sd-cos-sim(sd1 :: SD.StringDict, sd2 :: SD.StringDict) -> Number block:
  # shortcut for identical bags
  when sd1 == sd2: 1 end

  # if the magnitude of the products is 0, return 0 with a warning
  magnitude-product = sqrt(dot-product(sd1, sd1)) * sqrt(dot-product(sd2, sd2))
  if num-exact(magnitude-product) == 0:
    raise("One of the vectors being compared is zero, so I can't calculate its similarity. Does one of your rows have all zero values?")
  else:
    num-exact(num-round-to(dot-product(sd1, sd2) / magnitude-product, 10))
  end
end

# a wrapper function that exposes sd-cos-sim to row inputs
# check to ensure the rows have at least 2 non-restricted columns
fun cosine-similarity(r1 :: Row, r2 :: Row) -> Number block:
  cols = get-unrestricted-cols(r1)
  when cols.length() < 2:
    raise("Cosine and angle similarity require at least two columns to work with (not counting any existing 'ID' and 'DOC' columns)")
  end
  # convert each row to a StringDict, and compute cosine similarity
  sd-cos-sim(row-to-dict(cols, r1), row-to-dict(cols, r2))
end

# angle-similarity-lists: converts cosine similarity to degrees (0-90°).
# 0° means the DOCs are identical; 90° means completely dissimilar.
fun angle-similarity(r1 :: Row, r2 :: Row) -> Number:
  num-exact((num-acos(cosine-similarity(r1, r2)) * 180) / 3.14159265)
end


fun compute-similarity(t :: Table, id, fn) block:
  compare-to = row-n(t.filter({(r): r["ID"] == id}), 0)
  fun compare-row(r): fn(r, compare-to) end
  build-column(t, "similarity", compare-row)
end


#image-bag = convert-to-bag(image-to-color-names(shrink-images(image-corpus)))
#song-bag  = convert-to-bag(song-corpus)
#poem-bag  = convert-to-bag(remove-stop-words(normalize(poem-corpus)))
#text-bag  = convert-to-bag(remove-stop-words(normalize(text-corpus)))