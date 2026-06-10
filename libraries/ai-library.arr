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
include matrices


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

MODEL_DIGITS = 4

fun add-col(t, doc-col, col-name, doc-fn):
  build-column(t, col-name, lam(r): doc-fn(r[doc-col]) end)
end

fun add-width(t, doc-col): 
  add-col(t, doc-col, "WIDTH", image-width) 
end
fun add-height(t, doc-col): 
  add-col(t, doc-col, "HEIGHT", image-height) 
end
fun add-entropy(t, doc-col): 
  add-col(t, doc-col, "ENTROPY", {(img): 
      round-digits(num-exact(image-entropy(img)),
          MODEL_DIGITS)}) 
end
fun add-luminance(t, doc-col): 
  add-col(t, doc-col, "LUMINANCE", {(img): 
      round-digits(num-exact(image-luminance(img)),
          MODEL_DIGITS)}) 
end
fun add-symmetry-v(t, doc-col): 
  add-col(t, doc-col, "SYMMETRY-V", {(img): 
      round-digits(num-exact(image-symmetry-vertical(img)),
          MODEL_DIGITS)}) 
end
fun add-symmetry-h(t, doc-col): 
  add-col(t, doc-col, "SYMMETRY-H", {(img): 
      round-digits(num-exact(
image-symmetry-horizontal(img)),
          MODEL_DIGITS)}) 
end
fun add-color-names(t, doc-col): 
  add-col(t, doc-col, "COLOR-NAMES", dominant-rgb-colors) 
end

fun decorate-image-table(t, doc-col):
  fns = [list: add-width, add-height, add-luminance, add-entropy, add-symmetry-v, add-symmetry-h, add-color-names]
  L.fold(lam(shadow t, f): f(t, doc-col) end, t, fns)
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
end

fun add-length(t, doc-col): add-col(t, doc-col, "LENGTH", string-length) end
fun add-words(t, doc-col): add-col(t, doc-col, "WORDS", num-words) end
fun add-syllables(t, doc-col): add-col(t, doc-col, "SYLLABLES", num-syllables) end
fun add-sentences(t, doc-col): add-col(t, doc-col, "SENTENCES", num-sentences) end
fun add-grade(t, doc-col): add-col(t, doc-col, "GRADE-LEVEL", text-grade) end

fun decorate-text-table(t, doc-col):
  fns = [list: add-length, add-words, add-syllables, add-sentences, add-grade]
  L.fold(lam(shadow t, f): f(t, doc-col) end, t, fns)
end

fun is-non-empty-string(w :: String) -> Boolean:  w <> '' end
fun is-non-punct(c :: String) -> Boolean block:
  # Spaces are fine, anything between a-z and A-Z is fine
  lower-case-a-cp = string-to-code-point('a')
  lower-case-z-cp = string-to-code-point('z')
  upper-case-a-cp = string-to-code-point('A')
  upper-case-z-cp = string-to-code-point('Z')
  if (c == ' ') or (c == '\n'): true
  else:
    c-cp = string-to-code-point(c)
    ((c-cp >= lower-case-a-cp) and (c-cp <= lower-case-z-cp)) or
    ((c-cp >= upper-case-a-cp) and (c-cp <= upper-case-z-cp))
  end
end

fun replace-newlines(s): 
  if s == '\n': " " else: s end
end

fun lowercase(s :: String) -> String:
  string-explode(string-to-lower(s)).join-str("")
end

fun remove-punct(s :: String) -> String:
  string-explode(s)
    .filter(is-non-punct)
    .filter(is-non-empty-string)
    .join-str("")
end

fun remove-stops(s :: String) -> String:
  string-split-all(s, " ")
    .filter({(w): not(stop-words.member(w))})
    .filter(is-non-empty-string)
    .join-str(" ")
end

fun normalize-text-table(t :: Table, col :: String) -> Table:
  t.transform-column(
    col,
    {(txt): remove-stops(remove-punct(lowercase(txt)))}
    )
end

fun massage-string(w :: String) -> String block:
    lowercase-chars = string-explode(string-to-lower(w)).map(replace-newlines)
  fold({(a, b): a + b }, '', lowercase-chars.filter(is-non-punct))
end


fun is-all-uppercase(s :: String) -> Boolean:
  (string-length(s) > 0) and
  (string-to-upper(s) == s)
end

# columns that should always be ignored
restricted-cols = [list: "ID", "DOC", "LIKED", "DISLIKED", "TAGS", "SIMILARITTY", "STRENGTH", "COLOR-NAMES", "NORMALIZED"]
fun get-unrestricted-cols(r):
  r.get-column-names().filter({(c):
      not(restricted-cols.any({(rc): string-contains(c, rc) or is-all-uppercase(c)}))})
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

  sort-strings-ci(unique-words).foldl(
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



fun decorate-song-table(t, doc-col):
  fns = [list: add-longest-snap, add-longest-clap]
  L.fold(lam(shadow t, f): f(t, doc-col) end, t, fns)
end


###################################################################################
# Ratings, Recommendations, and Search

fun liked-ids(t):    t.filter({(r): r["LIKED"]    }).column("ID") end
fun disliked-ids(t): t.filter({(r): r["DISLIKED"] }).column("ID") end
fun tagged-ids(t, tag):   t
    .filter({(r): string-split-all(r["TAGS"], ",").map(string-trim).member(tag) })
    .column("ID")
end

# Given a table, recursively build the centroid as a StringDict
# by averaging each non-restricted column. Use exactnum to allow
# for easy comparison
fun add-centroid(t :: Table, name :: String, ids :: List<String>) -> Table block:
  matching = t.filter({(r): member(ids, r["ID"])})

  # for the rows with the passed IDs, walk over the columns in-order:
  #    hand-enter specific column names, 
  #    skip restricted ones,
  #    compute the average of anything else
  tuples = matching.column-names().map({(c):
      if c == "ID": {"ID";  name + " CENTROID"}
      else if c == "DOC":   {"DOC"; nothing}
      else if c == "LIKED":    {"LIKED"; false}
      else if c == "DISLIKED": {"DISLIKED"; false}
      else if restricted-cols.member(c): {c; ""}
      else: {c; rounded-exact(Stats.mean(matching.get-column(c)))}
      end
    })
  centroid = T.raw-row.make(raw-array-from-list(tuples))

  t.add-row(centroid)
end


# Given a model, find the centroids for likes and dislikes,
# if they exist. If neither does, raise an error.
# Otherwise, find the unlabeled row that is MOST similar
# to the like-centroid and the LEAST similar to the dislike one
fun recommend(t :: Table) -> Table block:
  likes    = liked-ids(t)
  dislikes  = disliked-ids(t)

  # make sure we have some ratings
  when (likes.length() + dislikes.length()) == 0:
    raise(Err.message-exception("No recommendations could be computed without at least one RATING"))
  end
  
  cols = get-unrestricted-cols(t.row-n(0))

  # Add "LIKE-DIST" and "DISLIKE-DIST"
  # If we have likes, build the centroid and populate LIKE-DIST
  # If we don't, just add the column and populate it with zeros
  # Do the same for dislikes
  shadow t = if likes.length() > 0:
    w-liked-centroid = add-centroid(t, "LIKE", likes)
    cosine-similarity(w-liked-centroid, "LIKE CENTROID", cols)
      .rename-column("cosine-similarity", "LIKE-DIST")
  else:
    t.build-column("LIKE-DIST", {(r): 0})
  end
  shadow t = if dislikes.length() > 0:
    w-disliked-centroid = add-centroid(t, "DISLIKE", dislikes)
    cosine-similarity(w-disliked-centroid, "DISLIKE CENTROID", cols)
      .rename-column("cosine-similarity", "DISLIKE-DIST")
  else:
    t.build-column("DISLIKE-DIST", {(r): 0})
  end

  # remove any already-rated rows, and both centroids
  unrated = t
    .filter({(r): (r["ID"] <> "LIKE CENTROID") and (r["ID"] <> "DISLIKE CENTROID")})

  # for every unlabeled DOC, compute the similarity from both
  # centroids. Then subtract dislike from like for a general
  # recommendation score, and sort from most-recommended to least
  unrated
    .build-column("STRENGTH",  {(r): r["LIKE-DIST"] - r["DISLIKE-DIST"]})
    .order-by("STRENGTH", false)
  #.drop("LIKE-DIST")
  #.drop("DISLIKE-DIST")
end

# build a centroid for every row w/this tag, then use that find similar images
# be sure to remove the centroid when finished
fun search-by-tag(t, tag) block:
  matching-ids = tagged-ids(t, tag)
  cols = get-unrestricted-cols(t.row-n(0))
  t-w-centroid = add-centroid(t, "TAG", matching-ids)
  angle-similarity(t-w-centroid, "TAG CENTROID", cols)
    .filter({(r): r["ID"] <> "TAG CENTROID"})
  #    .filter({(r): r["angle-similarity"] < 30})
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
# 1. simple-similarity — perfect equality
# 2. cosine-similarity — a continuous score from 0 to 1 measuring
#                        how similar the word frequency vectors are
# 3. angle-similarity  — converts cosine similarity to an angle (0-90°),
#                        where 0° means identical and 90° means nothing
#                        in common.
# 4. all-cols-similarity — same as cosine similarity, but auto-chooses the cols
################################################################

# simple-similarity: true iff the specified cols of the two rows 
# are identical
fun simple-similarity(t :: Table, id, cols :: List<String>) block:
  fun helper(r1 :: Row, r2 :: Row) -> Number block:
    vals1 = cols.map({(c): r1[c]})
    vals2 = cols.map({(c): r2[c]})
    if (vals1 == vals2): 1 else: 0 end
  end
  compare-to = t.filter({(r): r["ID"] == id}).row-n(0)
  fun compare-row(r): helper(r, compare-to) end
  t.build-column("simple-similarity", compare-row).order-by("simple-similarity", false)
end

# distance-similarity: returns the euclidean distance between
# points defined by the cols
fun distance-similarity(t :: Table, id, cols :: List<String>) block:
  fun helper(r1 :: Row, r2 :: Row) -> Number block:
    vals1 = cols.map({(c): r1[c]})
    vals2 = cols.map({(c): r2[c]})
    if cols.length() == 1: 
      abs(r1[cols.get(0)] - r2[cols.get(0)])
    else:
      sum-of-squares = L.fold2(lam(acc, vA, vB): acc + sqr(vA - vB) end,
        0,
        vals1,
        vals2)
      rounded-exact(sqrt(sum-of-squares))
    end
  end
  compare-to = t.filter({(r): r["ID"] == id}).row-n(0)
  fun compare-row(r): helper(r, compare-to) end
  t.build-column("distance-similarity", compare-row).order-by("distance-similarity", true)
end

# all-cols-similarity: returns 1 if the two bags contain the same words
# with the same frequencies (regardless of order). Otherwise 0.
fun all-cols-similarity(t :: Table, id) block:
  r = t.row-n(0)
  cols = get-unrestricted-cols(r).filter({(c): is-number(r[c])})
  when cols.length() == 0:
    raise(Err.message-exception("all-cols-similarity ignores certain columns (" + restricted-cols.join-str(", ") + "), but no other numeric columns were found"))
  end
  cosine-similarity(t, id, cols)
end


fun row-cosine-similarity(r1 :: Row, r2 :: Row, cols :: List<String>) -> Number block:
  # convert each row to a StringDict, and compute cosine similarity
  sd1 = row-to-dict(cols, r1)
  sd2 = row-to-dict(cols, r2)

  # shortcut for truly-equal vectors
  when sd1 == sd2: 1 end

  # if the magnitude of the products is 0, return 0 with a warning
  magnitude-product = sqrt(dot-product(sd1, sd1)) * sqrt(dot-product(sd2, sd2))
  if num-exact(magnitude-product) == 0:
    raise(Err.message-exception("One of the vectors being compared is zero, so I can't calculate its similarity. Does one of your rows have all zero values?"))
  else:
    rounded-exact(dot-product(sd1, sd2) / magnitude-product)
  end
end
# returns a number from 0 to 1 measuring how
# similar the two word-frequency vectors are. 1 = identical bags,
# 0 = no words in common. Uses the standard cosine similarity formula:
#   cos(θ) = (A · B) / (|A| * |B|)
fun cosine-similarity(t :: Table, id, cols :: List<String>) block:
  compare-to = t.filter({(r): r["ID"] == id}).row-n(0)
  fun compare-row(r): row-cosine-similarity(r, compare-to, cols) end
  t.build-column("cosine-similarity", compare-row).order-by("cosine-similarity", false)
end


# angle-similarity-lists: converts cosine similarity to degrees (0-90°).
# 0° means the DOCs are identical; 90° means completely dissimilar.
fun angle-similarity(t :: Table, id, cols :: List<String>) block:
  fun helper(r1 :: Row, r2 :: Row) -> Number:
    rounded-exact((num-acos(row-cosine-similarity(r1, r2, cols)) * 180) / PI)
  end
  compare-to = t.filter({(r): r["ID"] == id}).row-n(0)
  fun compare-row(r): helper(r, compare-to) end
  t.build-column("angle-similarity", compare-row).order-by("angle-similarity", true)
end



####################################################################
#
#  Decision Trees and Clustering


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
          yes-lines = prefix-lines(to-lines(yes),     "├✔─ ", "│   ")
          no-lines  = prefix-lines(to-lines(no), "└✘─ ", "    ")
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

# If both branches resolve to the same decide(label), collapse to that leaf;
# otherwise return the full node unchanged.
fun prune-or-node(
    yes-tree :: DecisionTree,
    no-tree  :: DecisionTree,
    full-node :: DecisionTree
    ) -> DecisionTree:
  cases(DecisionTree) yes-tree:
    | decide(yl) =>
      cases(DecisionTree) no-tree:
        | decide(nl) => if yl == nl: yes-tree else: full-node end
        | else      => full-node
      end
    | else => full-node
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
        yes-key-set = b.keys.foldl(lam(k, d): d.set(k, true) end, [string-dict:])
        yes-t = t.filter-by(col, lam(val): yes-key-set.has-key(to-string(val)) end)
        no-t  = t.filter-by(col, lam(val): not(yes-key-set.has-key(to-string(val))) end)
        if (yes-t.length() == 0) or (no-t.length() == 0): none
        else: some(cat-subset-split(col, b.origs, yes-t, no-t, b.err))
        end
    end
  end
end

# Try every column, and choose the split that minimizes weighted error
fun find-best-split(t :: Table, label-col :: String, quant-cols :: List<String>, cat-cols :: List<String>) -> Option<SplitInfo>:
  cat-bias   = 0.0  # 0 = no preference, higher = stronger
  quant-bias = 0.0  # 0 = no preference, higher = stronger
  fun effective-err(s :: SplitInfo) -> Number:
    cases(SplitInfo) s:
      | quant-split(_, _, _, _, e)      => e * (1 - quant-bias)
      | cat-subset-split(_, _, _, _, e) => e * (1 - cat-bias)
    end
  end
  all-candidates = 
    cat-cols.map(lam(col): find-best-cat-split(t, col, label-col) end)
    + quant-cols.map(lam(col): find-best-quant-split(t, col, label-col) end)
  all-candidates.foldl(lam(candidate, best-so-far):
      cases(Option) candidate:
        | none => best-so-far
        | some(c) =>
          cases(Option) best-so-far:
            | none    => candidate
            | some(b) => if effective-err(c) < effective-err(b): candidate else: best-so-far end
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
              yes-tree = iter(low,  max-depth - 1)
              no-tree  = iter(high, max-depth - 1)
              full = node(col, true, threshold, {(r): r[col] < threshold}, yes-tree, no-tree)
              prune-or-node(yes-tree, no-tree, full)
            | cat-subset-split(col, vals, yes-t, no-t, _) =>
              # For boolean columns, always use true as the predicate value.
              # The split is symmetric, so flipping just reorders the branches.
              flip       = ((vals.length() == 1) 
                and is-boolean(vals.first) 
                and (vals.first == false))
              norm-vals  = if flip: [list: true] else: vals  end
              norm-yes-t = if flip: no-t         else: yes-t end
              norm-no-t  = if flip: yes-t        else: no-t  end
              vals-keys = norm-vals.map(to-string)
              yes-tree = iter(norm-yes-t, max-depth - 1)
              no-tree  = iter(norm-no-t,  max-depth - 1)
              full = node(col, false, norm-vals, {(r): vals-keys.member(to-string(r[col]))}, yes-tree, no-tree)
              prune-or-node(yes-tree, no-tree, full)
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

fun generate-ngrams(corpus :: String, n :: Number) block:
  doc: "Consumes a string and N, and produces a list of records with N-grams and their counts."

  when n > MAX-GRAM-SIZE:
    raise(Err.message-exception("I have been programmed not to make n-grams larger than " + to-string(MAX-GRAM-SIZE)))
  end

  words = string-split-all(massage-string(corpus), " ")
    .filter(is-non-empty-string)

  fun join-words(w-list):
    for fold(acc from "", w from w-list):
      if acc == "": w else: acc + " " + w end
    end
  end

  fun get-ngrams(w-list):
    if w-list.length() < n:
      empty
    else:
      current-ngram = join-words(w-list.take(n))
      link(current-ngram, get-ngrams(w-list.rest))
    end
  end

  ngrams = get-ngrams(words)

  counts = for fold(dict from [string-dict:], ngram from ngrams):
    if dict.has-key(ngram):
      dict.set(ngram, dict.get-value(ngram) + 1)
    else:
      dict.set(ngram, 1)
    end
  end

  rows = for map(key from counts.keys().to-list()):
    [T.raw-row: {"n-gram"; key}, {"count"; counts.get-value(key)}]
  end

  T.table-from-rows
    .make(raw-array-from-list(rows))
    .order-by("count", false)
end

fun build-lang-model(corpus-str :: String) -> Table:
  doc: "Precomputes all n-gram tables and combines them into one table with a 'size' column."
  word-count = string-split-all(massage-string(corpus-str), " ")
    .filter(is-non-empty-string)
    .length()

  all-rows = for fold(acc from empty, n from L.range(1, MAX-GRAM-SIZE + 1)):
    these-rows = for fold(rows from empty, r from generate-ngrams(corpus-str, n).all-rows()):
      link([T.raw-row: {"size"; n}, {"n-gram"; r["n-gram"]}, {"count"; r["count"]}], rows)
    end
    acc + these-rows
  end

  T.table-from-rows
    .make(raw-array-from-list(all-rows))
    .order-by("count", false)

end

fun completions(model :: Table, input :: String) block:
  input-lst = string-split-all(massage-string(input), " ")
    .filter(is-non-empty-string)

  input-length = input-lst.length()

  shadow input = if input-length >= MAX-GRAM-SIZE:
    input-lst.reverse()
      .take(MAX-GRAM-SIZE)
      .reverse()
      .join-str(" ")
  else: input-lst.join-str(" ")
  end

  gram-size = num-min(string-split-all(input, " ").length() + 1, MAX-GRAM-SIZE)

  filtered = model
    .filter({(r): (r["size"] == gram-size) and string-starts-with(r["n-gram"], input)})
    .transform-column("n-gram", {(ngram): string-split-all(ngram, " ").reverse().get(0)})

  # Calculate total count to compute percentages
  total-count = for fold(shadow sum from 0, r from filtered.all-rows()):
    sum + r["count"]
  end

  # Add percentage column
  filtered.build-column("probability", {(r):
    if total-count == 0:
      0
    else:
      rounded-exact((r["count"] / total-count))
    end
  })
end

fun next-word-probability(model :: Table, first :: String, second :: String):
  choices = completions(model, first)

  total = for fold(acc from 0, r from choices.all-rows()):
    acc + r["count"]
  end

  if total == 0:
    0
  else:
    matching = choices.filter({(r): r["n-gram"] == massage-string(second)})
    if matching.length() == 0:
      0
    else:
      matching.row-n(0)["count"] / total
    end
  end
end


fun choose-completion(model :: Table, input :: String):
  words = string-split-all(massage-string(input), " ")
    .filter(is-non-empty-string)
  last-word = if words.length() == 0: "" else: words.reverse().get(0) end

  choices = completions(model, input)
    .filter({(r): r["n-gram"] <> last-word})
  row-count = choices.length()

  if row-count == 0:
    choose-completion(model, words.rest.join-str(" "))
  else if row-count == 1:
    choices.row-n(0)["n-gram"]
  else:
    choices.row-n(random(row-count - 1))["n-gram"]
  end
end

# truncate the input to the last MAX-GRAM-SIZE words, 
# and choose a completion
fun add-next-word(model :: Table, input :: String) -> String:
  words = string-split-all(input, " ")
    
  start = words.reverse().take(num-min(words.length(), MAX-GRAM-SIZE)).reverse().join-str(" ")
  input + " " + choose-completion(model, start)
end

fun draw-lines(txt):
  fun build-image(str):
    overlay(text(str, 20, "black"), 
      square(25, "solid", "transparent"))
  end
  
  words = string-split-all(txt, " ")
  fun build-lines(remaining, current-line):
    cases (List) remaining:
      | empty =>
        if current-line == "":
          empty
        else:
          [list: build-image(current-line)]
        end
      | link(word, rest) =>
        candidate =
          if current-line == "": word
          else: current-line + " " + word
          end
        if (current-line == "") or (string-length(candidate) <= 80):
          build-lines(rest, candidate)
        else:
          link(build-image(current-line), build-lines(rest, word))
        end
    end
  end
  above-align-list("left", build-lines(words, ""))
end

fun generate-from(model :: Table, input):
  reactor:
    init: input,
    to-draw: draw-lines,
    on-tick: lam(i): add-next-word(model, i) end,
    seconds-per-tick: 0.1
  end
    .interact()
    .get-value()
end


####################################################################
#
#  Principal Component Analysis over a Pyret table, written on top
#  of the standard `matrices` library.
#
#  Public entry point:
#      pca(t :: Table, cols :: List<String>) -> PCAResult
#
#  The result is a `pca-result` value with two interesting methods:
#
#    .fn()       -> a function (List<Number> -> List<Number>) that
#                   projects a row (in `cols` order) onto the
#                   principal components.
#
#    ._output()  -> prints the equivalent Pyret source code for a
#                   projection function over Rows, suitable for
#                   building a new table of pc1, pc2, ... columns.
####################################################################

# ------------------------------------------------------------------
#  Column validation
# ------------------------------------------------------------------
fun check-columns(t :: Table, cols :: List<String>) -> Nothing block:
  when cols.length() == 0:
    raise("pca: must request at least one column")
  end
  table-cols = t.column-names()
  for each(c from cols) block:
    when not(table-cols.member(c)):
      raise("pca: column not found in table: " + c)
    end
    col-data = t.get-column(c)
    when not(col-data.all(is-number)):
      raise("pca: column is not numeric: " + c)
    end
  end
end

# ------------------------------------------------------------------
#  Eigendecomposition of a symmetric matrix via the (unshifted)
#  QR algorithm.  Iterates  A_{k+1} = R_k Q_k  where  Q_k R_k = A_k
#  and accumulates  Q_total = Q_0 Q_1 ... Q_{n-1}.  For symmetric
#  positive-semidefinite matrices (like a covariance matrix) this
#  converges to a diagonal of eigenvalues, with the eigenvectors
#  showing up as the columns of Q_total.
# ------------------------------------------------------------------
fun symmetric-eig(a :: Matrix, iters :: Number)
  -> { evals :: List<Number>, evecs :: Matrix }:
  start = { cur: a, q-total: identity-matrix(a.rows) }
  final = for fold(state from start, _ from range(0, iters)):
    qr = state.cur.qr-decomposition()
    { cur: qr.R * qr.Q, q-total: state.q-total * qr.Q }
  end
  evals = for map(i from range(0, a.rows)):
    final.cur.get(i, i)
  end
  { evals: evals, evecs: final.q-total }
end

# Pair eigenvalues with their eigenvectors (pulled out of evecs as
# columns) and sort them in descending order of eigenvalue.
# Returns a matrix whose ROWS are the sorted eigenvectors -- exactly
# the layout that the projection multiply  comp-matrix * centered_x
# wants, and the same layout `_output` walks one row at a time.
fun sort-by-eigenvalue(evals :: List<Number>, evecs :: Matrix)
  -> { evals :: List<Number>, vecs :: Matrix }:
  pairs = for map_n(i from 0, ev from evals):
    { ev: ev, vec: evecs.col(i).to-list() }
  end
  sorted = pairs.sort-by(
    lam(p1, p2): p1.ev > p2.ev end,
    lam(p1, p2): roughly-equal(p1.ev, p2.ev) end)
  { evals: sorted.map(lam(p): p.ev end),
    vecs:  lists-to-matrix(sorted.map(lam(p): p.vec end)) }
end

# ------------------------------------------------------------------
#  Helper for printing roughnums in the source-code output
# ------------------------------------------------------------------
fun num-string(n :: Number) -> String:
  num-to-string(num-to-roughnum(n))
end

# ------------------------------------------------------------------
#  The result data type
# ------------------------------------------------------------------
data PCAResult:
  | pca-result(
      cols        :: List<String>,
      means       :: List<Number>,
      eigenvalues :: List<Number>,
      components  :: Matrix) with:

    # Pretty-prints as the Pyret source code for the projection
    # function.  Useful for copy/paste into a student's program.
    method _output(self) block:
      components = self.components.to-lists()
      param-list = self.cols
        .map(lam(c): c + " :: Number" end)
        .join-str(", ")
      centered-bindings = for map2(c from self.cols, m from self.means):
        "  centered-" + c + " = r[\"" + c + "\"] - " + num-string(m)
      end
      pc-fields = for map_n(i from 1, comp from components):
        terms = for map2(coef from comp, c from self.cols):
          "(" + num-string(coef) + " * centered-" + c + ")"
        end
        "    {\"pc" + num-to-string(i) + "\"; " + terms.join-str(" + ") + "}"
      end
      source =
        [list:
          "fun project(r :: Row) -> Object:",
          centered-bindings.join-str("\n"),
          "T.raw-row.make(raw-array-from-list([list: ",
          pc-fields.join-str(",\n"),
          "]))",
          "end"
        ]
      print(source.join-str("\n"))
      vs-value(circle(1, "solid", "transparent"))
    end,

    # Hands back the actual projection function.
    # Input:  a row of numbers in the same order as `cols`.
    # Output: that row's coordinates on each principal component.
    method project-row(self, r :: Row) -> Row block:
      # Pull the requested columns out of the row, in `cols` order.
      centered = list-to-col-matrix(
        for map2(c from self.cols, m from self.means):
          r[c] - m
        end)
      pc-values = (self.components * centered).to-list()
      pc-pairs  = for map_n(i from 1, v from pc-values):
        {"pc" + num-to-string(i); v}
      end
      T.raw-row.make(raw-array-from-list(pc-pairs))
    end,

    method project-table(self, t :: Table) -> Table:
      T.table-from-rows
        .make(raw-array-from-list(t.all-rows().map(self.project-row)))
    end
end

# ------------------------------------------------------------------
#  Public entry point
# ------------------------------------------------------------------
fun pca(t :: Table, cols :: List<String>) -> PCAResult block:
  check-columns(t, cols)

  # Pull the requested columns and compute the per-column means.
  raw-cols = cols.map(lam(c): t.get-column(c) end)
  n        = raw-cols.first.length()
  when n < 2:
    raise("pca: need at least 2 rows to compute a covariance")
  end
  means    = raw-cols.map(
    lam(col): col.foldl(lam(a, b): a + b end, 0) / col.length() end)

  # Build the centered data matrix X (n rows by p columns), with each
  # variable laid out as a column via vectors-to-matrix.
  centered-vecs = for map2(col from raw-cols, m from means):
    list-to-vector(col.map(lam(x): x - m end))
  end
  x = vectors-to-matrix(centered-vecs)        # n x p

  # Sample covariance: C = X^T X / (n - 1)   (p x p, symmetric PSD)
  cov = (x.transpose() * x).scale(1 / (n - 1))

  # Eigendecomposition, then sort components by eigenvalue (desc).
  eig    = symmetric-eig(cov, 200)
  sorted = sort-by-eigenvalue(eig.evals, eig.evecs)

  pca-result(cols, means, sorted.evals, sorted.vecs)
end

#|
  Example use:
    my-table = table: x :: Number, y :: Number, z :: Number
      row: 2.5, 2.4, 0.5
      row: 0.5, 0.7, 1.1
      row: 2.2, 2.9, 0.3
      row: 1.9, 2.2, 0.8
      row: 3.1, 3.0, 0.1
      row: 2.3, 2.7, 0.6
    end
    result = pca(my-table, [list: "x", "y", "z"])
    result                    # _output prints the projection source
    project = result.fn()     # the live projection function
    project([list: 2.5, 2.4, 0.5])
|#


####################################################################
#
#  Playing around with neural nets
#
####################################################################


#  Externally, a *layer* is a table of neurons
#  Internally, we use a record-list to make list operations easier
type Neuron = {
  weights :: Table,
  bias :: Number,
  activation :: String     # "sigmoid" or "step"
}

type Layer   = List<Neuron>
type Network = List<Layer>

# Logistic activation.  Squashes z into the open interval (0, 1).
fun sigmoid(z :: Number) -> Number:
  1 / (1 + num-exp(0 - z))
end

# Step activation.  1 if z is non-negative, else 0.
fun step(z :: Number) -> Number:
  if z >= 0: 1 else: 0 end
end


# Apply the appropriate activation to z.
fun apply-activation(name :: String, z :: Number) -> Number:
  ask:
    | name == "sigmoid" then: sigmoid(z)
    | name == "step"    then: step(z)
    | otherwise: raise(Err.message-exception("Unknown activation: " + name))
  end
end


# The sum of element-wise products of `inputs` and `weights`
fun weighted-sum(inputs :: List<Number>, weights :: List<Number>) -> Number:
  products = L.map2(lam(x, w): x * w end, inputs, weights)
  # foldl's lambda receives (accumulator, element) — accumulator first.
  L.foldl(lam(total, p): total + p end, 0, products)
end



fun make-neuron(
    weights :: Table, # rows are (input-name, weight) pairs
    bias :: Number,
    activation :: String
    ) -> Neuron:
  { weights: weights, bias: bias, activation: activation }
end

# Run one neuron on one list of inputs
fun neuron-output(n :: Neuron, inputs :: List<Number>) -> Number:
  weights = n.weights.column("weight")       # Get weights out of the neuron
  z = weighted-sum(inputs, weights) + n.bias # Take the weighted sum and add the bias.
  apply-activation(n.activation, z)          # Apply the activation
end


# ----------------------------------------------------------------
#  Unit 3  —  one neuron learns one example
#
#  The perceptron rule (no calculus needed):
#       w_i  :=  w_i + lr * (target - output) * x_i
#       bias :=  bias + lr * (target - output)
#  Works cleanly for step-activated neurons and motivates the more
#  general "wiggle each weight and see how loss changes" approach
#  that Unit 6 will introduce.
# ----------------------------------------------------------------

# Return a fresh weights table with the same input-names but the weight column replaced.
fun update-weights-column(
    weight-table :: Table,
    new-weights :: List<Number>
    ) -> Table:
  weight-table
    .drop("weight")
    .add-column("weight", new-weights)
end

# Nudge a neuron's weights and bias toward producing `target` on these `inputs` 
fun perceptron-update(
    n :: Neuron,
    inputs :: List<Number>,
    target :: Number,
    learning-rate :: Number
    ) -> Neuron:
  output = neuron-output(n, inputs)
  error  = target - output

  old-weights = n.weights.column("weight")
  new-weights = L.map2(
    lam(w, x): w + (learning-rate * error * x) end,
    old-weights, inputs)

  {
    weights:    update-weights-column(n.weights, new-weights),
    bias:       n.bias + (learning-rate * error),
    activation: n.activation
  }
end

# Run every neuron in the layer on the same inputs.  Returns one
# output per neuron, in the layer's neuron order.  Those outputs
# become the inputs to the next layer.
fun layer-output(layer :: Layer, inputs :: List<Number>) -> List<Number>:
  L.map(lam(n): neuron-output(n, inputs) end, layer)
end

# forward-pass - compose the layers via fold and feed them inputs. 
# Should we call it 'forward' instead?
fun run(net :: Network, inputs :: List<Number>) -> List<Number>:
  L.foldl(
    lam(current, layer): layer-output(layer, current) end,
    inputs,
    net)
end


# The squared difference between two numbers.  Always non-negative
fun squared-error(predicted :: Number, actual :: Number) -> Number:
  (predicted - actual) * (predicted - actual)
end

# Mean squared error of `net` on every row of `data`.
# consumes the feature-names (input cols, in order) and 
# target-name - (output col)
# Assumes the network has a single output neuron, so we take the `.first` of its output list
fun dataset-loss(
    net :: Network,
    data_ :: Table,
    feature-names :: List<String>,
    target-name :: String
    ) -> Number:
  feature-cols = L.map(lam(name): data_.column(name) end, feature-names)
  targets      = data_.column(target-name)

  # For each row index i: build that row's input list, run the net,
  # square the error.
  per-row-losses = L.map_n(
    lam(i, target):
      inputs = L.map(lam(col): L.get(col, i) end, feature-cols)
      prediction = run(net, inputs).first
      squared-error(prediction, target)
    end,
    0, targets)

  total = L.foldl(lam(acc, x): acc + x end, 0, per-row-losses)
  total / L.length(per-row-losses)
end

# make a net where a specific weight has been shifted by delta
fun perturb-weight(
    net :: Network,
    layer-idx :: Number,
    neuron-idx :: Number,
    weight-idx :: Number,
    delta :: Number
    ) -> Network:
  doc: "Return a copy of `net` with one weight (at the given coords) shifted by `delta`."
  L.map_n(lam(li, layer):
      if li == layer-idx:
        L.map_n(lam(ni, neuron):
            if ni == neuron-idx:
              old-weights = neuron.weights.column("weight")
              new-weights = L.map_n(
                lam(wi, w): if wi == weight-idx: w + delta else: w end end,
                0, old-weights)
              {
                weights:    update-weights-column(neuron.weights, new-weights),
                bias:       neuron.bias,
                activation: neuron.activation
              }
            else: neuron
            end
          end, 0, layer)
      else: layer
      end
    end, 0, net)
end

# make a net where a specific bias has been shifted by delta
fun perturb-bias(
    net :: Network,
    layer-idx :: Number,
    neuron-idx :: Number,
    delta :: Number
    ) -> Network:
  doc: "Return a copy of `net` with one neuron's bias shifted by `delta`."
  L.map_n(lam(li, layer):
      if li == layer-idx:
        L.map_n(lam(ni, neuron):
            if ni == neuron-idx:
              {
                weights:    neuron.weights,
                bias:       neuron.bias + delta,
                activation: neuron.activation
              }
            else: neuron
            end
          end, 0, layer)
      else: layer
      end
    end, 0, net)
end


#  For every weight in the network: wiggle it up by ε, wiggle it
#  down by ε, look at how much the total loss changed, divide by
#  2ε.  That number is the estimated ∂loss/∂weight.  Same for
#  every bias.
#
#  Result shape: a "shadow Network" identical in shape to `net`,
#  but where each weight is its gradient and each bias is its
#  gradient.  `apply-gradient` will walk both in lockstep.
# ----------------------------------------------------------------

# Estimate ∂loss/∂param for every weight and bias by central
#       differences:
#                       loss(p + ε)  −  loss(p − ε)
#            grad  ≈  ──────────────────────────────
#                                 2ε
#       Returns a Network of the same shape as `net`.
fun numerical-gradient(
    net :: Network,
    data_ :: Table,
    feature-names :: List<String>,
    target-name :: String,
    epsilon :: Number
    ) -> Network:
  fun loss-at(perturbed :: Network) -> Number:
    dataset-loss(perturbed, data_, feature-names, target-name)
  end

  L.map_n(lam(li, layer):
      L.map_n(lam(ni, neuron):
          old-weights = neuron.weights.column("weight")
          # One gradient per weight.
          weight-grads = L.map_n(
            lam(wi, _):
              (loss-at(perturb-weight(net, li, ni, wi, epsilon))
                  - loss-at(perturb-weight(net, li, ni, wi, 0 - epsilon)))
                / (2 * epsilon)
            end,
            0, old-weights)
          # One gradient for the bias.
          bias-grad =
            (loss-at(perturb-bias(net, li, ni, epsilon))
                - loss-at(perturb-bias(net, li, ni, 0 - epsilon)))
            / (2 * epsilon)
          {
            weights:    update-weights-column(neuron.weights, weight-grads),
            bias:       bias-grad,
            activation: neuron.activation
          }
        end, 0, layer)
    end, 0, net)
end


# Update every weight and bias by stepping AGAINST the gradient,
# returning (old − (learning-rate · grad)) 
fun apply-gradient(
    net :: Network,
    grad :: Network,
    learning-rate :: Number
    ) -> Network:
  L.map2(lam(layer, grad-layer):
      L.map2(lam(neuron, grad-neuron):
          old-weights  = neuron.weights.column("weight")
          grad-weights = grad-neuron.weights.column("weight")
          new-weights  = L.map2(
            lam(w, gw): w - (learning-rate * gw) end,
            old-weights, grad-weights)
          {
            weights:    update-weights-column(neuron.weights, new-weights),
            bias:       neuron.bias - (learning-rate * grad-neuron.bias),
            activation: neuron.activation
          }
        end, layer, grad-layer)
    end, net, grad)
end

############################################################
#  The training loop:
#
#  Repeat for `epochs` rounds:
#     1. estimate the gradient on the whole dataset
#     2. step every weight & bias against it
#     3. record this epoch's loss
#  Return both the trained network and a loss-history table
#  (columns: epoch, loss) that students can plot directly

# train a given network on given data_ for given epochs
# return {trained-network, loss-history}, where the history
# is a table with columns for epoch and loss
fun train(
    net :: Network,
    data_ :: Table,
    feature-names :: List<String>,
    target-name :: String,
    learning-rate :: Number,
    epochs :: Number
    ) -> { trained :: Network, loss-history :: Table }:

  EPSILON = 0.001    # finite-difference step size

  fun loop(current, epoch, history):
    if epoch == epochs:
      { trained: current, loss-history: history }
    else:
      grad     = numerical-gradient(current, data_, feature-names, target-name, EPSILON)
      stepped  = apply-gradient(current, grad, learning-rate)
      new-loss = dataset-loss(stepped, data_, feature-names, target-name)
      new-row = [T.raw-row: {"epoch"; epoch + 1}, {"loss"; new-loss}]
      loop(stepped, epoch + 1, history.add-row(new-row))
    end
  end
  initial-loss = dataset-loss(net, data_, feature-names, target-name)
  initial-history = table: epoch :: Number, loss :: Number
    row: 0, initial-loss
  end
  loop(net, 0, initial-history)
end
