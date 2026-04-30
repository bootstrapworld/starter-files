use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr")

################################################################
# Bootstrap AI Library, as of Fall 2026
provide *

# re-export every symbol from Core
import url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr") as Core
import csv as csv
include string-dict
provide from Core:
  *,
  type Posn,
  module Err,
  module Sets,
  module T,
  module SD,
  module R,
  module L,
  module Stats
end
# export every symbol from starter2024 except for those we override
import starter2024 as Starter
provide from Starter:
    * hiding(translate, filter, range, sort, sin, cos, tan)
end

# we use custom renderers for AI 
include valueskeleton
include option

SMALL-IMAGE-WIDTH = 100
fun shrink-image(img :: Image) -> Image:
  factor = SMALL-IMAGE-WIDTH / image-width(img)
  scale(factor, img)
end

DIGITS = 10
fun rounded-exact(r):
  num-exact(num-round-to(r, DIGITS))
end


########################################################################
# Some helpers that might eventually make their way into the core library

# A standard list of English stop words (common words like "the", "and",
# "a" etc.) that carry little meaning and can be ignored when comparing
# DOCs for similarity. From Fox (1990).
stop-words = [list: "the", "and", "a", "that", "was", "for", "with", "not", "on", "at", "i", "had", "are", "or", "an", "they", "one", "would", "all", "there", "their", "him", "has", "when", "if", "out", "what", "up", "about", "into", "can", "other", "some", "time", "two", "then", "do", "now", "such", "man", "our", "even", "made", "after", "many", "must", "years", "much", "your", "down", "should", "of", "to", "in", "is", "he", "it", "as", "his", "be", "by", "this", "but", "from", "have", "you", "which", "were", "her", "she", "will", "we", "been", "who", "more", "no", "so", "said", "its", "than", "them", "only", "new", "could", "these", "may", "first", "any", "my", "like", "over", "me", "most", "also", "did", "before", "through", "where", "back", "way", "well", "because", "each", "people", "state", "mr", "how", "make", "still", "own", "work", "long", "both", "under", "never", "same", "while", "last", "might", "day", "since", "come", "great", "three", "go", "few", "use", "without", "place", "old", "small", "home", "went", "once", "school", "every", "united", "number", "does", "away", "water", "fact", "though", "enough", "almost", "took", "night", "system", "general", "better", "why", "end", "find", "asked", "going", "knew", "toward", "just", "those", "too", "world", "very", "good", "see", "men", "here", "get", "between", "year", "another", "being", "life", "know", "us", "off", "against", "came", "right", "states", "take", "himself", "during", "again", "around", "however", "mrs", "thought", "part", "high", "upon", "say", "used", "war", "until", "always", "something", "public", "put", "think", "head", "far", "hand", "set", "nothing", "point", "house", "later", "eyes", "next", "program", "give", "white", "room", "social", "young", "present", "order", "second", "possible", "light", "face", "important", "among", "early", "need", "within", "business", "felt", "best", "ever", "least", "got", "mind", "want", "others", "although", "open", "area", "done", "certain", "door", "different", "sense", "help", "perhaps", "group", "side", "several", "let", "national", "given", "rather", "per", "often", "god", "things", "large", "big", "become", "case", "along", "four", "power", "saw", "less", "thing", "today", "interest", "turned", "members", "family", "problem", "kind", "began", "thus", "seemed", "whole", "itself"]

fun add-col(t, col-name, doc-fn):
  build-column(t, col-name, lam(r): doc-fn(r["DOC"]) end)
end

fun add-entropy(t): add-col(t, "entropy", image-entropy) end
fun add-luminance(t): add-col(t, "luminance", image-luminance) end
fun add-symmetry-v(t): add-col(t, "symmetry-v", image-symmetry-vertical) end
fun add-symmetry-h(t): add-col(t, "symmetry-h", image-symmetry-horizontal) end
fun add-color-names(t): add-col(t, "color-names", image-color-names) end

fun add-grade(t): add-col(t, "grade", text-grade) end
fun add-cleaned(t, remove-stops):  
  add-col(t, "cleaned", lam(doc): text-clean(doc, remove-stops) end) 
end

# Given a string, produce the grade level according to Flesch-Kincaid:
# Grade = .39(words/sentences)+11.8(syllables/words)-15.59
# https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests
fun text-grade(txt :: String) -> Number:
  total-words = num-words(txt)
  total-sentences = num-sentences(txt)
  total-syllables = num-syllables(txt)
  words-per-sentence = total-words / total-sentences
  syllables-per-word = (total-syllables / total-words)
  flesch-kincaid = ((0.39 * words-per-sentence) + (11.8 * syllables-per-word)) - 15.59
  rounded-exact(flesch-kincaid)
end

fun text-streak(str :: String, target :: String) -> Number:
  words = string-split-all(str, " ")
  init-state = { current: 0, max-seen: 0 }

  final-stats = for fold(acc from init-state, w from words):
    if w == target:
      new-current = acc.current + 1
      { current: new-current, max-seen: num-max(new-current, acc.max-seen) }
    else:
      { current: 0,           max-seen: acc.max-seen                       }
    end
  end
  final-stats.max-seen
where:
  text-streak("sun sea sun sun sand", "sun")     is 2
  text-streak("sea sea sea", "sea")              is 3
  text-streak("sand sun sea", "cyan")            is 0
  text-streak("sun sun sand sun sun sun", "sun") is 3
end

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

fun massage-string(w :: String) -> String block:
  lowercase-chars = string-explode(string-to-lower(w))
  fold({(a, b): a + b }, '', lowercase-chars.filter(is-non-punct))
end

fun is-non-empty-string(w :: String) -> Boolean:  w <> '' end

# 1) massaging the string (lowercase + remove punctuation)
# 2) splitting on spaces
# 3) filtering out any empty strings
fun text-clean(txt :: String, remove-stops :: Boolean) -> String block:

  string-split-all(massage-string(txt), ' ')
    .filter(is-non-empty-string)
    .filter({(w):
      if remove-stops: not(stop-words.member(w))
      else: true
      end})
    .join-str(' ')
end


fun is-all-uppercase(s :: String) -> Boolean:
  (string-length(s) > 0) and
  (string-to-upper(s) == s)
end

# columns that should always be ignored
restricted-cols = [list: "ID", "DOC", "RATING", "TAGS", "SIMILARITTY", "STRENGTH", "COLOR-NAMES"]
fun get-unrestricted-cols(r):
  r.get-column-names().filter({(c):
      not(restricted-cols.any({(rc): string-contains(c, rc) or is-all-uppercase(c)}))})
end


# a doc-mutating function
fun shrink-images(t):
  t.transform-column("DOC", shrink-image)
end

# a table-normalizing function
fun normalize(self):
  cols = get-unrestricted-cols(self.t.row-n(0))

  for fold(acc from self.t, col from cols):
    if string-to-lower(col) == col:
      vals = self.t.column(col)
      min-val = L.fold(num-min, vals.first, vals.rest)
      max-val = L.fold(num-max, vals.first, vals.rest)
      rng = max-val - min-val
      # rng = 0 means all value identical
      if rng == 0:
        acc  
      else:
        acc.transform-column(col,
          {(v): (v - min-val) / rng})
      end
    else:
      acc
    end
  end
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
fun add-bag-cols(t, col :: String) -> Table block:
  # list-of-words-to-sd converts a list of strings into a StringDict
  # mapping each unique word to its frequency count.
  # For example, ["a", "b", "a"] -> {"a": 2, "b": 1}
  fun list-of-words-to-sd(xx :: List<String>) -> SD.StringDict<Number> block:
    msd = [SD.mutable-string-dict:]
    for each(x from xx):
      old-value = cases(Option) (msd.get-now(x)):
        | none => 0
        | some(v) => v
      end
      msd.set-now(x, old-value + 1)
    end
    msd.freeze()
  end


  # convert each row's text into a normalized word list
  all-word-lists = t.column(col).map(lam(s): string-split-all(s, ' ') end)

  # collect the union of all unique words across every row
  unique-words = all-word-lists.foldl(
    lam(word-list, acc):
      word-list.foldl(lam(w, shadow acc): acc.add(w) end, acc)
    end,
    Sets.list-to-set([list:]))
    .to-list()

  # for each unique word, add a column whose values are the
  # per-row frequency of that word. We recompute the word-frequency
  # dict inside each build-column call since build-column only gives
  # us the row, not the row index.
  unique-words.foldl(
    lam(word, shadow t):
      t.build-column(word, lam(r):
          words = string-split-all(r[col], ' ')
          sd = list-of-words-to-sd(words)
          cases(Option) sd.get(word):
            | none => 0
            | some(shadow count) => count
          end
        end)
    end,
    t)
    .drop(col)
end

animals-url = "https://docs.google.com/spreadsheets/d/1VeR2_bhpLvnRUZslmCAcSRKfZWs_5RNVujtZgEl6umA/export?format=csv"

###################################################################################
# Song-Specific Helpers

fun add-longest-snap(t):
  t.build-column("longest 🫰", lam(r): text-streak(r["DOC"], "🫰") end)
end
fun add-longest-clap(t):
  t.build-column("longest 👏", lam(r): text-streak(r["DOC"], "👏") end)
end
fun add-longest-stomp(t):
  t.build-column("longest 🦶", lam(r): text-streak(r["DOC"], "🦶") end)
end



###################################################################################
# Ratings, Recommendations, and Search

# Given a table, recursively build the centroid as a StringDict
# by averaging each non-restricted column. Use exactnum to allow
# for easy comparison
fun build-centroid(t :: Table, name) -> Row:
  cols = t.column-names().filter({(c):
      not(member(restricted-cols.append([list: "NORMALIZED", "COLOR-NAMES"]), c))
    })
  fun add-col-avgs(shadow cols, acc):
    cases (List) cols:
      | empty => acc
      | link(col, rest) =>
        if cols.member(col) block:
          avg = if t.get-column(col).length() == 0: 0
          else: Stats.mean(t.get-column(col))
          end
          val = rounded-exact(avg)
          add-col-avgs(rest, L.link({col; num-exact(val)}, acc))
        else:
          add-col-avgs(rest, acc)
        end
    end
  end
  # compute all the averages in reverse-order (since add-col-avgs also reverses)
  averages = add-col-avgs(cols.reverse(), [list:])
  restricted = [list:
    {"ID";name + " CENTROID"},
    {"DOC";""}, {"RATING";""},
    {"TAGS";""}
  ]
  T.raw-row.make(raw-array-from-list(L.append(restricted, averages)))
end

_centroid-test = table: x, y row: 2, 1 row: 4, 5 end
examples:
  build-centroid(_centroid-test, "test") is
  [T.raw-row: {"ID";"test CENTROID"},{"DOC";""}, {"RATING";""}, {"TAGS";""},{"x";3},{"y";3}]
end

fun likes(t):    t.filter({(r): r["RATING"] == "like"    }) end
fun dislikes(t): t.filter({(r): r["RATING"] == "dislike" }) end
fun unrated(t):  t.filter({(r): r["RATING"] == "-"       }) end

fun find-by-tag(t :: Table, tag :: String): 
  filter(t, {(r): string-contains(r["TAGS"], tag) }) 
end


# Given a model, find the centroids for likes and dislikes,
# if they exist. If neither does, raise an error.
# Otherwise, find the unlabeled row that is MOST similar
# to the like-centroid and the LEAST similar to the dislike one
fun recommend(t :: Table) -> Table block:
  liked     = likes(t)
  disliked  = dislikes(t)
  not-rated = unrated(t)

  # make sure we have some ratings
  when (liked.length() + disliked.length()) == 0:
    raise(Err.message-exception("No recommendations could be computed without at least one RATING"))
  end

  # compute the centroids
  preference = build-centroid(liked, "likes")
  aversion   = build-centroid(disliked, "dislikes")

  # for every unlabeled DOC, compute the similarity from both
  # centroids. Then subtract dislike from like for a general
  # recommendation score, and sort from most-recommended to least
  not-rated
    .build-column("like",       {(r):
      if liked.length() == 0: 0 else: cosine-similarity(preference, r) end })
    .build-column("dislike",    {(r):
      if disliked.length() == 0: 0 else: cosine-similarity(aversion, r) end })
    .build-column("STRENGTH",  {(r): r["like"] - r["dislike"]})
    .order-by("STRENGTH", false)
    .drop("like")
    .drop("dislike")
end

# given a row, return a sorted table in cosine-similarity order
fun match-row(t, row):
  t
    .build-column("SIMILARITY to " + row["ID"], {(r): cosine-similarity(row, r)})
    .order-by("SIMILARITY to " + row["ID"], false)
end

# build a centroid for every row w/this tag, then use that to match-row
fun search-by-tag(t, tag):
  matching-docs = filter(t, 
    {(r): string-split-all(r["TAGS"], ",").member(tag) })
  centroid = build-centroid(matching-docs, tag)
  match-row(t, centroid)
end


##################################################################################
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
    raise(Err.message-exception("Simple similarity requires that all rows have a 'DOC' column"))
  end
  if (r1["DOC"] == r2["DOC"]): 1 else: 0 end
end

# bag-similarity: returns 1 the two bags contain the same words
# with the same frequencies (regardless of order). Otherwise 0.
fun bag-similarity(r1 :: Row, r2 :: Row) -> Number block:
  cols = get-unrestricted-cols(r1)
  when cols.length() == 0:
    raise(Err.message-exception("Bag similarity ignores certain columns (" + restricted-cols.join-str(", ") + "), but no other columns were found"))
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
    raise(Err.message-exception("One of the vectors being compared is zero, so I can't calculate its similarity. Does one of your rows have all zero values?"))
  else:
    rounded-exact(dot-product(sd1, sd2) / magnitude-product)
  end
end

# a wrapper function that exposes sd-cos-sim to row inputs
# check to ensure the rows have at least 2 non-restricted columns
fun cosine-similarity(r1 :: Row, r2 :: Row) -> Number block:
  cols = get-unrestricted-cols(r1)
  when cols.length() < 2:
    raise(Err.message-exception("Cosine and angle similarity require at least 2 quantitative columns."))
  end
  # convert each row to a StringDict, and compute cosine similarity
  sd-cos-sim(row-to-dict(cols, r1), row-to-dict(cols, r2))
end

# angle-similarity-lists: converts cosine similarity to degrees (0-90°).
# 0° means the DOCs are identical; 90° means completely dissimilar.
fun angle-similarity(r1 :: Row, r2 :: Row) -> Number:
  num-exact((num-acos(cosine-similarity(r1, r2)) * 180) / 3.14159265)
end

# sort a table in terms of similarity-to-a-specific-row, as
# specified by the ID
fun compute-similarity(t :: Table, id, fn) block:
  compare-to = t.filter({(r): r["ID"] == id}).row-n(0)
  fun compare-row(r): fn(r, compare-to) end
  t.build-column("SIMILARITY", compare-row)
end

#|
   ########################################################################
   # Some examples of models, and how to use them

   ########################################################################
   # Load the spreadsheet and define our tables
   data-sheet = load-spreadsheet(
  "https://docs.google.com/spreadsheets/d/1e_3op5DNDUOAjInXtlrzQ0fKZSuASd65E9-VEjNyteo/")

   images-url = "https://docs.google.com/spreadsheets/d/1e_3op5DNDUOAjInXtlrzQ0fKZSuASd65E9-VEjNyteo/export?format=csv"
   image-table = transform-column(load-table: ID, DOC, RATING, TAGS
      source: csv.csv-table-url(images-url, {
              header-row: true,
              infer-content: false
      })
  end, "DOC", image-url)

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
|#




fun simple-clustering(d :: List<Number>, n-clusters :: Number) -> List<{Number; Number}>:
  doc: "Partitions a sorted list into N clusters and returns {min; max} tuples."
  if (d.length() == 0) or (n-clusters <= 0):
    [list: ]
  else:
    sorted-data = d.sort()
    len = sorted-data.length()

    # Calculate items per cluster (rounding up to ensure we cover all data)
    chunk-size = num-ceiling(len / n-clusters)

    # Use range to generate starting indices [0, chunk-size, 2*chunk-size...]
    indices = L.range(0, n-clusters)

    # For each index, grab the 'chunk-size' elements and find boundaries
    map(lam(i):
        start-index = i * chunk-size
        # Get the sub-segment of the list
        chunk = sorted-data.take(num-min(len, start-index + chunk-size)).drop(start-index)

        if chunk.length() > 0:
          { chunk.get(0); chunk.last() }
        else:
          # Handle cases where n-clusters is larger than the number of data points
          none
        end
      end, indices).filter(lam(x): not(is-none(x)) end)
  end
where:
  simple-clustering([list: 10, 2, 8, 1, 9, 3], 2) is [list: {1; 3}, {8; 10}]
  simple-clustering([list: 5, 1, 10], 2) is [list: {1; 5}, {10; 10}]
end


fun dist(a, b): abs(a - b) end

fun find-closest(val, centroids :: List<Number>) -> Number:
  centroids.rest.foldl(lam(best, current):
      if dist(val, current) < dist(val, best): current else: best end
    end, centroids.first)
end

fun k-means-clustering(points :: List<Number>, n-clusters :: Number) -> List<{Number; Number}>:
  fun run-iterations(centroids, gas):
    assignments = points.map(lam(v): {val: v, center: find-closest(v, centroids)} end)
    new-centroids = centroids.map(lam(c):
        shadow group = assignments.filter(lam(a): a.center == c end).map(lam(a): a.val end)
        if group.length() > 0:
          group.foldl(lam(acc, v): acc + v end, 0) / group.length()
        else: c
        end
      end)
    if (new-centroids == centroids) or (gas <= 0): assignments  # return assignments, not centroids
    else: run-iterations(new-centroids, gas - 1)
    end
  end

  final-assignments = run-iterations(points.take(n-clusters), 10)
  final-centers = Sets.list-to-list-set(final-assignments.map(lam(a): a.center end)).to-list()

  # Now grouping is a simple filter on already-computed assignments — no find-closest calls
  final-centers
    .map(lam(c):
      cluster = final-assignments.filter(lam(a): a.center == c end).map(lam(a): a.val end).sort()
      {cluster.get(0); cluster.last()}
    end)
    .sort-by({(a, b): a.{0} < b.{0}}, {(a, b): a == b})
where:
  k-means-clustering([list: 1, 10, 2, 11], 2) is [list: {1; 2}, {10; 11}]
end

fun get-boundary-thresholds(intervals :: List<{Number; Number}>) -> List<Number>:
  doc: "Returns the N-1 midpoints between adjacent cluster intervals."
  fun find-midpoints(curr-intervals):
    cases(List) curr-intervals:
      | empty => empty
      | link(first-int, rest-int) =>
        if rest-int.length() == 0: empty
        else:
          next-int = rest-int.get(0)
          link((first-int.{1} + next-int.{0}) / 2, find-midpoints(rest-int))
        end
    end
  end
  if intervals.length() <= 1: empty
  else:
    find-midpoints(intervals.sort-by({(a, b): a.{0} < b.{0}}, {(a, b): a == b}))
  end
where:
  get-boundary-thresholds([list: {1; 2}, {10; 12}]) is [list: 6]
  get-boundary-thresholds([list: {1; 2}, {10; 12}, {20; 22}]) is [list: 6, 16]
end

fun cluster-by-fn(t :: Table, col :: String, n-clusters :: Number, clustering-fn):
  doc: "Partitions table t by clustering col into n-clusters groups."
  values = Sets.list-to-list-set(t.get-column(col)).to-list()
  intervals = clustering-fn(t.get-column(col), n-clusters)
  splits = get-boundary-thresholds(intervals).push(Math.max(values) + 1).sort()
  var prev-split = Math.min(values)
  for fold(grouped from table: interval, subtable end, s from splits) block:
    subtable_ = t.filter-by(col, {(val): (val < s) and (val >= prev-split)})
      .order-by(col, true)
    label = easy-num-repr(prev-split, 4) + " >= " + col + " < " + easy-num-repr(s, 4)
    prev-split := s
    grouped.stack(table: interval, subtable
        row: label, subtable_
      end)
  end
end

fun k-means-cluster-col(t :: Table, col :: String, n-clusters :: Number):
  cluster-by-fn(t, col, n-clusters, k-means-clustering)
end

fun simple-cluster-col(t :: Table, col :: String, n-clusters :: Number):
  cluster-by-fn(t, col, n-clusters, simple-clustering)
end

fun prefix-lines(lines, first-prefix, cont-prefix):
  cases(List) lines:
    | empty => empty
    | link(first, rest) =>
      link(first-prefix + first, rest.map(lam(l): cont-prefix + l end))
  end
end


data DecisionTree:
  | decide(label :: String)
  | node(
      col :: String,
      is-quant :: Boolean,
      val :: Any,
      splitter :: (Any -> Boolean),
      yes :: DecisionTree,
      no :: DecisionTree)

sharing:
  method classify(self, r :: Row) -> String:
    cases(DecisionTree) self:
      | decide(lbl) => lbl
      | node(col, is-quant, val, splitter, yes, no) =>
        if splitter(r): yes.classify(r)
        else: no.classify(r)
        end
    end
  end,

  method to-fun(self) -> (Row -> String):
    lam(r): self.classify(r) end
  end,

  method _output(self) block:
    fun render-val(x):
      if is-boolean(x): to-string(x)
      else if is-number(x): easy-num-repr(x, 8)
      else: "\"" + to-string(x) + "\""
      end
    end
    fun to-lines(tree :: DecisionTree) -> List<String>:
      cases(DecisionTree) tree:
        | decide(lbl) => [list: "→ " + lbl]
        | node(col, is-quant, val, splitter, yes, no) =>
          header = if is-quant:
            col + " < " + easy-num-repr(val, 8) + "?"
          else if is-link(val):
            if val.length() == 1:
              col + " == " + render-val(val.first) + "?"
            else:
              col + " in {" + val.map(render-val).join-str(", ") + "}?"
            end
          else:
            col + " == " + render-val(val) + "?"
          end
          yes-lines = prefix-lines(to-lines(yes),     "├── ", "│   ")
          no-lines  = prefix-lines(to-lines(no), "└── ", "    ")
          [list: header] + yes-lines + no-lines
      end
    end
    print(to-lines(self).join-str("\n"))
    vs-value(circle(1, "solid", "transparent"))
  end
end

# given a DecisionTree, produce the classifier function
fun dt-fun(tree :: DecisionTree): tree.to-fun() end

# given a DecisionTree, produce copy-and-pastable code for
# the classifier function
fun dt-code(c :: DecisionTree) block:
  fun render-val(x):
    if is-boolean(x): to-string(x)
    else if is-number(x): easy-num-repr(x, 8)
    else: "\"" + to-string(x) + "\""
    end
  end
  fun to-lines(tree :: DecisionTree) -> List<String>:
    cases(DecisionTree) tree block:
      | decide(lbl) => [list: "\"" + lbl + "\""]
      | node(col, is-quant, val, splitter, yes, no) =>
        header = if is-quant:
            "if r[\"" + col + "\"] < " + easy-num-repr(val, 8) + ":"
        else if is-link(val):
            if val.length() == 1:
              "if r[\"" + col + "\"] == " + render-val(val.first) + ":"
            else:
              conditions = val.map(lam(x):
                  "(r[\"" + col + "\"] == " + render-val(x) + ")"
                end).join-str(" or ")
              "if " + conditions + ":"
            end
          else:
            "if r[\"" + col + "\"] == " + render-val(val) + ":"
          end
        yes-lines = prefix-lines(to-lines(yes), "   ", "   ")
        no-lines  = prefix-lines(to-lines(no), "   ", "   ")
        [list: header] + yes-lines + [list: "else:"] + no-lines + [list: "end"]
    end
  end
  classifier-fn-lines = [list: "fun classifier(r):"] +
  to-lines(c).map({(l): "  " + l}) +
  [list: "end"]
  print(classifier-fn-lines.join-str("\n"))
  circle(1, "solid", "transparent")
end

data SplitInfo:
  | quant-split(col :: String, threshold :: Number, low :: Table, high :: Table, err :: Number)
  | cat-subset-split(col :: String, vals :: List, yes :: Table, no :: Table, err :: Number)
end

fun split-err(s :: SplitInfo) -> Number:
  cases(SplitInfo) s:
    | quant-split(_, _, _, _, e)      => e
    | cat-subset-split(_, _, _, _, e) => e
  end
end

# find the best quantitative column and threshold on which to split
fun find-best-quant-split(t :: Table, col :: String, label-col :: String) -> Option<SplitInfo>:
  doc: "Find the error-minimizing threshold on `col` by sweeping sorted (val, label) pairs."
  col-vals = t.get-column(col)
  labels   = t.get-column(label-col)
  n        = col-vals.length()
  if n < 2: none
  else:
    # Zip and sort (col-val, label) pairs by col-val ascending.
    pairs = L.map2(lam(v, l): {v; l} end, col-vals, labels)
      .sort-by({(a, b): a.{0} < b.{0}}, {(a, b): a.{0} == b.{0}})

    # "right" histogram starts as the overall label counts; "left" starts empty.
    overall = labels.foldl(lam(l, acc):
        k = to-string(l)
        cases(Option) acc.get(k):
          | none    => acc.set(k, 1)
          | some(m) => acc.set(k, m + 1)
        end
      end, [string-dict:])

    fun max-val(d):
      d.keys-list().foldl(lam(k, m): num-max(d.get-value(k), m) end, 0)
    end

    # Sweep through sorted pairs. Between pair[i-1] and pair[i], if their col-vals
    # differ, midpoint is a legal threshold — score it from the running histograms.
    fun sweep(rest, prev-val, left-c, right-c, left-n, right-n, best):
      cases(List) rest:
        | empty => best
        | link(cur, more) =>
          cv = cur.{0}
          cl = cur.{1}
          new-best = cases(Option) prev-val:
            | none    => best
            | some(pv) =>
              if cv > pv:
                err = (left-n - max-val(left-c)) + (right-n - max-val(right-c))
                thr = (pv + cv) / 2
                cases(Option) best:
                  | none    => some({thr: thr, err: err})
                  | some(b) => if err < b.err: some({thr: thr, err: err}) else: best end
                end
              else: best
              end
          end
          # Move cur from right to left.
          k = to-string(cl)
          nl = cases(Option) left-c.get(k):
            | none    => left-c.set(k, 1)
            | some(m) => left-c.set(k, m + 1)
          end
          nr = cases(Option) right-c.get(k):
            | none    => right-c  # shouldn't happen
            | some(m) => right-c.set(k, m - 1)
          end
          sweep(more, some(cv), nl, nr, left-n + 1, right-n - 1, new-best)
      end
    end

    best-split = sweep(pairs, none, [string-dict:], overall, 0, n, none)

    cases(Option) best-split:
      | none => none
      | some(b) =>
        low  = t.filter-by(col, lam(v): v < b.thr end)
        high = t.filter-by(col, lam(v): v >= b.thr end)
        if (low.length() == 0) or (high.length() == 0): none
        else: some(quant-split(col, b.thr, low, high, b.err))
        end
    end
  end
end

# Find the best categorical subset split via Breiman's prefix sweep.
# Sorts distinct values by P(reference-class | value), then sweeps prefixes —
# provably optimal for binary classification, strong heuristic for multi-class.
fun find-best-cat-split(t :: Table, col :: String, label-col :: String) -> Option<SplitInfo>:
  col-vals = t.get-column(col)
  labels   = t.get-column(label-col)
  total    = col-vals.length()

  # Single pass: per-value records {orig, total, lbls: label->count} + overall label histogram.
  stats = L.fold2(lam(acc, c, l):
      ck = to-string(c)
      lk = to-string(l)
      new-overall = cases(Option) acc.overall.get(lk):
        | none    => acc.overall.set(lk, 1)
        | some(n) => acc.overall.set(lk, n + 1)
      end
      cur = cases(Option) acc.by-val.get(ck):
        | none    => {orig: c, total: 0, lbls: [string-dict:]}
        | some(r) => r
      end
      new-lbls = cases(Option) cur.lbls.get(lk):
        | none    => cur.lbls.set(lk, 1)
        | some(n) => cur.lbls.set(lk, n + 1)
      end
      new-cur = {orig: cur.orig, total: cur.total + 1, lbls: new-lbls}
      {by-val: acc.by-val.set(ck, new-cur), overall: new-overall}
    end, {by-val: [string-dict:], overall: [string-dict:]}, col-vals, labels)

  fun max-val(d):
    d.keys-list().foldl(lam(k, m): num-max(d.get-value(k), m) end, 0)
  end
  fun add-counts(hist, lbls):
    lbls.keys-list().foldl(lam(lk, acc):
        v = lbls.get-value(lk)
        cases(Option) acc.get(lk):
          | none    => acc.set(lk, v)
          | some(m) => acc.set(lk, m + v)
        end
      end, hist)
  end
  fun sub-counts(hist, lbls):
    lbls.keys-list().foldl(lam(lk, acc):
        v = lbls.get-value(lk)
        cases(Option) acc.get(lk):
          | none    => acc
          | some(m) => acc.set(lk, m - v)
        end
      end, hist)
  end

  distinct-keys = stats.by-val.keys-list()
  if distinct-keys.length() <= 1: none
  else:
    # Reference class = overall majority.
    overall-keys = stats.overall.keys-list()
    ref-key = overall-keys.foldl(lam(k, b):
        if stats.overall.get-value(k) > stats.overall.get-value(b): k else: b end
      end, overall-keys.first)

    # For each distinct value, compute P(ref | v); sort ascending.
    keyed-vals = distinct-keys.map(lam(ck):
        s = stats.by-val.get-value(ck)
        ref-count = cases(Option) s.lbls.get(ref-key):
          | none    => 0
          | some(n) => n
        end
        {key: ck, orig: s.orig, total: s.total, lbls: s.lbls, frac: ref-count / s.total}
      end)
      .sort-by({(a, b): a.frac < b.frac}, {(a, b): a.frac == b.frac})

    # Sweep prefixes: at each step, the value just moved is added to the "yes" side.
    fun sweep(rest, left-c, right-c, left-n, right-n, pkeys, porigs, best):
      cases(List) rest:
        | empty => best
        | link(cur, more) =>
          new-left-c  = add-counts(left-c, cur.lbls)
          new-right-c = sub-counts(right-c, cur.lbls)
          new-left-n  = left-n + cur.total
          new-right-n = right-n - cur.total
          new-pkeys   = link(cur.key, pkeys)
          new-porigs  = link(cur.orig, porigs)
          new-best = cases(List) more:
            | empty      => best  # nothing left for the right side
            | link(_, _) =>
              err = (new-left-n - max-val(new-left-c)) + (new-right-n - max-val(new-right-c))
              cand = some({err: err, keys: new-pkeys, origs: new-porigs})
              cases(Option) best:
                | none    => cand
                | some(b) => if err < b.err: cand else: best end
              end
          end
          sweep(more, new-left-c, new-right-c, new-left-n, new-right-n, new-pkeys, new-porigs, new-best)
      end
    end

    best-prefix = sweep(keyed-vals, [string-dict:], stats.overall, 0, total, empty, empty, none)

    cases(Option) best-prefix:
      | none => none
      | some(b) =>
        yes-keys = b.keys
        yes-t = t.filter-by(col, lam(val): yes-keys.member(to-string(val)) end)
        no-t  = t.filter-by(col, lam(val): not(yes-keys.member(to-string(val))) end)
        if (yes-t.length() == 0) or (no-t.length() == 0): none
        else: some(cat-subset-split(col, b.origs, yes-t, no-t, b.err))
        end
    end
  end
end

# Try every column, and choose the split that minimizes weighted error
fun find-best-split(t :: Table, label-col :: String, quant-cols :: List<String>, cat-cols :: List<String>) -> Option<SplitInfo>:
  all-candidates = 
    quant-cols.map(lam(col): find-best-quant-split(t, col, label-col) end)
    + cat-cols.map(lam(col): find-best-cat-split(t, col, label-col) end)
  all-candidates.foldl(lam(candidate, best-so-far):
      cases(Option) candidate:
        | none => best-so-far
        | some(c) =>
          cases(Option) best-so-far:
            | none    => candidate
            | some(b) => if split-err(c) < split-err(b): candidate else: best-so-far end
          end
      end
    end, none)
end


fun build-tree(t :: Table, cols :: List<String>, label-col :: String, max-depth) -> DecisionTree:
  first-row = t.row-n(0)
  quant-cols = cols.filter(lam(c): is-number(first-row[c]) end)
  cat-cols   = cols.filter(lam(c): not(is-number(first-row[c])) end)

  fun iter(shadow t, shadow max-depth):  # cols removed from signature
    unique-labels = L.distinct(t.get-column(label-col))
    if (unique-labels.length() <= 1) or (max-depth <= 0):
      decide(most-common(t, label-col))
    else:
      cases(Option) find-best-split(t, label-col, quant-cols, cat-cols):  # pass both lists
        | none => decide(most-common(t, label-col))
        | some(s) =>
          cases(SplitInfo) s:
            | quant-split(col, threshold, low, high, _) =>
              node(col, true, threshold, {(r): r[col] < threshold },
                iter(low,  label-col, max-depth - 1),
                iter(high, label-col, max-depth - 1))
            | cat-subset-split(col, vals, yes-t, no-t, _) =>
              vals-keys = vals.map(to-string)
              node(col, false, vals,
                {(r): vals-keys.member(to-string(r[col])) },
                iter(yes-t, label-col, max-depth - 1),
                iter(no-t,  label-col, max-depth - 1))
          end
      end
    end
  end
  iter(t, max-depth)
end

# Returns the most frequently-occuring value in a column to use as a prediction
fun most-common(t :: Table, col :: String) -> String:
  vals = t.get-column(col)
  if vals.length() == 0: "unknown"
  else:
    result = vals.foldl(lam(v, acc):
        key = to-string(v)
        new-count = cases(Option) acc.counts.get(key):
          | none    => 1
          | some(n) => n + 1
        end
        new-counts = acc.counts.set(key, new-count)
        new-best = if new-count > acc.best-count: {best: v, best-count: new-count}
        else: {best: acc.best, best-count: acc.best-count}
        end
        {counts: new-counts, best: new-best.best, best-count: new-best.best-count}
      end, {counts: [string-dict:], best: vals.first, best-count: 0})
    to-string(result.best)
  end
end

fun classify(t :: Table, col, classifier) block:
  new-col = col + " (predicted)"
  fn = if (is-DecisionTree(classifier)): classifier.classify else: classifier end
  p-table = build-column(t, new-col, fn)
  if (t.column-names().member(col)):
    test-f = {(r): if (r[col] == r[new-col]): "✅" else: "❌" end}
    new-cols = t.column-names()
      .filter({(s): s <> col})
      .append([list: col, new-col, "Correct?"])
    p-table.build-column("Correct?", test-f)
      .select-columns(new-cols)
  else:
    p-table
  end

end

# Produces a table comparing actual values from 'col' to predictions
fun confusion-matrix(t :: Table, col :: String, classifier) -> Table:
  fn = if (is-DecisionTree(classifier)): classifier.classify else: classifier end
  labels = L.distinct(t.get-column(col)).sort()
  fun actual-rows(actual-val):
    t.filter-by(col, lam(r): r == actual-val end)
  end
  fun count-normalized(actual-val, predicted-val):
    actual = actual-rows(actual-val)
    total = actual.length()
    matched = actual.filter(lam(r): fn(r) == predicted-val end).length()
    if total == 0: 0.0
    else: num-exact(num-round-to(matched / total, 3))
    end
  end
  matrix-rows = labels.map(lam(lbl):
      contents = L.link({col; lbl}, labels.map(lam(pred):
            {"predicted-" + pred; count-normalized(lbl, pred)}
          end))
      T.raw-row.make(raw-array-from-list(contents))
    end)
  T.table-from-rows
    .make(raw-array-from-list(matrix-rows))
    .rename-column(col, "actual-" + col)
end

### N-GRAMS ##################################
MAX-GRAM-SIZE = 5

fun generate-ngram-table(corpus :: String, n :: Number) block:
  doc: "Consumes a string and N, and produces a list of records with N-grams and their counts."

  when n > MAX-GRAM-SIZE:
    raise(Err.message-exception("I have been programmed not to make n-grams larger than " + to-string(MAX-GRAM-SIZE)))
  end

  # Split the text into a list of individual words
  words = string-split-all(massage-string(corpus), " ")
    .filter(is-non-empty-string)

  # Helper: Joins a list of strings into a single space-separated string
  fun join-words(w-list):
    for fold(acc from "", w from w-list):
      if acc == "": 
        w 
      else: 
        acc + " " + w 
      end
    end
  end

  # Helper: Recursively extracts N-grams of length 'n'
  fun get-ngrams(w-list):
    if w-list.length() < n:
      empty
    else:
      current-ngram = join-words(w-list.take(n))
      link(current-ngram, get-ngrams(w-list.rest))
    end
  end

  ngrams = get-ngrams(words)

  # Count the frequencies of each N-gram using a String Dictionary
  counts = for fold(dict from [string-dict:], ngram from ngrams):
    if dict.has-key(ngram):
      dict.set(ngram, dict.get-value(ngram) + 1)
    else:
      dict.set(ngram, 1)
    end
  end

  # Map the dictionary keys and values into a list of records
  rows = for map(key from counts.keys().to-list()):
    [T.raw-row: 
      {"n-gram"; key}, 
      {"count"; counts.get-value(key) }]
  end


  T.table-from-rows
    .make(raw-array-from-list(rows))
    .order-by("count", false)
end

fun completions(corpus, input) block:
  input-lst = string-split-all(massage-string(input), " ")
    .filter(is-non-empty-string)

  input-length = input-lst.length()
  corpus-length = string-split-all(massage-string(corpus), " ")
    .filter(is-non-empty-string)
    .length()
  max-length = num-min(corpus-length, MAX-GRAM-SIZE)

  # if the input-length is longer than
  # the corpus just take the end
  shadow input = if input-length >= max-length:
    input-lst.reverse()
      .take(num-min(corpus-length, max-length - 1))
      .reverse()
      .join-str(" ")
  else: input-lst.join-str(" ")
  end

  gram-size = num-min(string-split-all(input, " ").length() + 1, MAX-GRAM-SIZE)

  n-grams = generate-ngram-table(corpus, gram-size)
    .filter({(r): string-starts-with(r["n-gram"], input)})
    .transform-column("n-gram", {(ngram): string-split-all(ngram, " ").reverse().get(0)})
  n-grams
end

fun best-completion(corpus, input):
  choices = completions(corpus, input)
  row-count = choices.length()

  if row-count == 1:
    choices.row-n(0)["n-gram"]
  else:
    choices.row-n(random(row-count))["n-gram"]
  end
end

fun add-next-word(corpus, input): 
  next-word = best-completion(corpus, input) 
  input + " " + next-word
end

fun generate-from(corpus, input):
  reactor:
    init: input,
    on-tick: lam(i): add-next-word(corpus, i) end,
    seconds-per-tick: 0.3
  end
    .interact()
    .get-value()
end