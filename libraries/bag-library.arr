
################################################################
# Bootstrap Bag of Words Library, as of Fall 2026

provide *

# Re-export everything from starter2024, except for functions we override
import starter2024 as Starter
include from Starter:
    * hiding(translate, filter, range, sort, sin, cos, tan)
end
include valueskeleton


########################################################################
# Model Data Structure
# We want some custom rendering, so we need to define our own datatype
# This can also be extended later, should we use a StringDict for BOW

MAX-DOC-LEN = 51

data Model:
  | model(t :: Table) with:
    method _output(self) block:
      cols = self.t.column-names()
      # re-make the table, truncating any string vals > MAX-DOC-LEN
      t = for fold(t from self.t, col from cols):
        t.transform-column(col, lam(v):
            if not(is-string(v) and (string-length(v) > MAX-DOC-LEN)): v
            else: string-substring(v, 0, MAX-DOC-LEN - 3) + "..."
            end
          end)
      end
      vs-value(t)
    end
end

# add a DOC to the model
fun add-doc(m, id, doc):
  row = [T.raw-row: {"ID"; id}, {"DOC"; doc}]
  model(m.t.empty().add-row(row).stack(m.t))
end

# columns that should always be ignored
restricted-cols = [list: "ID", "DOC", "RATING", "TAGS"]
fun get-unrestricted-cols(r):
  r.get-column-names().filter({(c): not(member(restricted-cols, c))})
end

########################################################################
# Model Data Structure
# Load the spreadsheet and define our tables
data-sheet = load-spreadsheet(
  "https://docs.google.com/spreadsheets/d/1e_3op5DNDUOAjInXtlrzQ0fKZSuASd65E9-VEjNyteo/")

image-corpus = model(transform-column(
    load-table: ID, DOC, RATING, TAGS
      source: data-sheet.sheet-by-name("Images", true)
    end,
    "DOC",
    image-url))

mystery-image = image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/mystery.png")

poem-corpus = model(load-table: ID, DOC, RATING, TAGS
    source: data-sheet.sheet-by-name("Poems", true)
  end)

mystery-poem = "The sun is big, but the sea is all"

song-corpus = model(load-table: ID, DOC, RATING, TAGS
    source: data-sheet.sheet-by-name("Songs", true)
  end)

mystery-song = "👏 👏 🫰 🫰 👏 🫰 👏 🫰 🫰 🫰 🫰 🫰 🫰 🫰 👏 👏 🫰"


text-corpus = model(load-table: ID, DOC, RATING, TAGS
    source: data-sheet.sheet-by-name("Text", true)
  end)

# from https://en.wikipedia.org/wiki/Okapi
mystery-text = "The okapi is classified under the family Giraffidae, along with its closest extant relative, the giraffe. Its distinguishing characteristics are its long neck, and large, flexible ears. Male okapis have horn-like protuberances called ossicones. "


##############################################################################################################
# Image Helpers

# add-color-names :: Model -> Model
# Addsa column in which each image has been converted to a string of
# space-separated color names ("red", "green", or "blue"),
# representing the dominant channel of each non-transparent pixel
fun add-color-names(m :: Model) -> Model block:
  fun dominant-color(pixel) -> String:
    if (pixel.alpha == 0): ""
    else if (pixel.red >= pixel.green) and (pixel.red >= pixel.blue): "red"
    else if (pixel.green >= pixel.red) and (pixel.green >= pixel.blue): "green"
    else: "blue"
    end
  end
  model(m.t.build-column("COLOR-NAMES", lam(r): image-to-color-list(r["DOC"])
          .filter(lam(pixel): pixel.alpha > 0 end)
          .map(dominant-color)
          .join-str(" ")
      end))
end

SMALL-IMAGE-WIDTH = 100
fun shrink-images(m :: Model) -> Model:
  model(m.t.transform-column("DOC", lam(img):
        factor = SMALL-IMAGE-WIDTH / image-width(img)
        scale(factor, img)
      end))
end

# For every row, compute luminance of the DOC image
fun add-luminance(m :: Model) -> Model:
  model(m.t.build-column("LUMINANCE", lam(r):
        avg-luminance = Stats.mean(image-to-color-list(r["DOC"]).map(luminance))
        num-exact(num-round-to(avg-luminance, 10))
      end))
end

# For every row, compute entropy of the DOC image
fun add-entropy(m :: Model) -> Model block:
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
  model(m.t.build-column("ENTROPY", lam(r):
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
      end))
end

# For every row, compute the dominant color of the DOC image
fun add-color(m :: Model) -> Model:
  model(m.t.build-column("MAIN-COLOR", lam(r):
        fun pixel-color(p): (p.red * sqr(256)) + (p.green * 256) + p.blue end
        color-encodings = image-to-color-list(r["DOC"]).map(pixel-color)
        num-exact(num-round-to(Stats.mean(color-encodings), 10))
      end))
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

# A standard list of English stop words (common words like "the", "and",
# "a" etc.) that carry little meaning and can be ignored when comparing
# DOCs for similarity. From Fox (1990).
standard-stop-words = [list: "the", "and", "a", "that", "was", "for", "with", "not", "on", "at", "i", "had", "are", "or", "an", "they", "one", "would", "all", "there", "their", "him", "has", "when", "if", "out", "what", "up", "about", "into", "can", "other", "some", "time", "two", "then", "do", "now", "such", "man", "our", "even", "made", "after", "many", "must", "years", "much", "your", "down", "should", "of", "to", "in", "is", "he", "it", "as", "his", "be", "by", "this", "but", "from", "have", "you", "which", "were", "her", "she", "will", "we", "been", "who", "more", "no", "so", "said", "its", "than", "them", "only", "new", "could", "these", "may", "first", "any", "my", "like", "over", "me", "most", "also", "did", "before", "through", "where", "back", "way", "well", "because", "each", "people", "state", "mr", "how", "make", "still", "own", "work", "long", "both", "under", "never", "same", "while", "last", "might", "day", "since", "come", "great", "three", "go", "few", "use", "without", "place", "old", "small", "home", "went", "once", "school", "every", "united", "number", "does", "away", "water", "fact", "though", "enough", "almost", "took", "night", "system", "general", "better", "why", "end", "find", "asked", "going", "knew", "toward", "just", "those", "too", "world", "very", "good", "see", "men", "here", "get", "between", "year", "another", "being", "life", "know", "us", "off", "against", "came", "right", "states", "take", "himself", "during", "again", "around", "however", "mrs", "thought", "part", "high", "upon", "say", "used", "war", "until", "always", "something", "public", "put", "think", "head", "far", "hand", "set", "nothing", "point", "house", "later", "eyes", "next", "program", "give", "white", "room", "social", "young", "present", "order", "second", "possible", "light", "face", "important", "among", "early", "need", "within", "business", "felt", "best", "ever", "least", "got", "mind", "want", "others", "although", "open", "area", "done", "certain", "door", "different", "sense", "help", "perhaps", "group", "side", "several", "let", "national", "given", "rather", "per", "often", "god", "things", "large", "big", "become", "case", "along", "four", "power", "saw", "less", "thing", "today", "interest", "turned", "members", "family", "problem", "kind", "began", "thus", "seemed", "whole", "itself"]

# normalize the "DOC" column by:
# 1) massaging the string (lowercase + remove punctuation)
# 2) splitting on spaces
# 3) filtering out any empty strings
fun normalize(m :: Model, remove-stops :: Boolean) -> Model block:
  fun is-non-empty-string(w :: String) -> Boolean:  w <> '' end
  model(m.t.build-column("NORMALIZED",
      lam(r): string-split-all(massage-string(string-to-lower(r["DOC"])), ' ')
          .filter(is-non-empty-string)
          .filter({(w):
            if remove-stops: not(standard-stop-words.member(w))
            else: true
            end})
          .join-str(' ')
      end))
end

# grade-level :: Model -> Model
# consumes text and produces the great level according
# to Flesch-Kincaid:
# Grade = .39(words/sentences)+11.8(syllables/words)-15.59
# https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests
fun add-grade-level(m :: Model) -> Model:
  model(m.t.build-column("GRADE-LEVEL",
      lam(r):
        total-words = num-words(r["DOC"])
        total-sentences = num-sentences(r["DOC"])
        total-syllables = num-syllables(r["DOC"])
        num-exact(
          num-round-to(
            ((0.39 * (total-words / total-sentences)) +
              (11.8 * (total-syllables / total-words))) -
            15.59,
            10))
      end))
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
fun build-centroid(m :: Model) -> Row:
  cols = m.t.column-names().filter({(c):
      not(member(restricted-cols.append([list: "NORMALIZED", "COLOR-NAMES"]), c))
    })
  fun add-col-avgs(shadow cols, acc):
    cases (List) cols:
      | empty => acc
      | link(col, rest) =>
        if cols.member(col) block:
          avg = if m.t.get-column(col).length() == 0: 0
          else: Stats.mean(m.t.get-column(col))
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

_centroid-test = model(table: x, y row: 2, 1 row: 4, 5 end)
examples:
  build-centroid(_centroid-test) is [T.raw-row: {"ID";"CENTROID"},{"DOC";""}, {"RATING";""}, {"TAGS";""},{"x";3},{"y";3}]
end

fun likes(m):    model(filter(m.t, {(r): r["RATING"] == "like"    })) end
fun dislikes(m): model(filter(m.t, {(r): r["RATING"] == "dislike" })) end
fun unrated(m):  model(filter(m.t, {(r): r["RATING"] == "-"       })) end



# Given a model, find the centroids for likes and dislikes,
# if they exist. If neither does, raise an error.
# Otherwise, find the unlabeled row that is MOST similar
# to the like-centroid and the LEAST similar to the dislike one
fun recommend(m :: Model) -> Model block:
  liked     = likes(m)
  disliked  = dislikes(m)
  not-rated = unrated(m)

  # make sure we have some ratings
  when (liked.t.length() + disliked.t.length()) == 0:
    raise("No recommendations could be computed without at least one RATING")
  end

  # compute the centroids
  preference = build-centroid(liked)
  aversion   = build-centroid(disliked)

  # for every unlabeled DOC, compute the similarity from both
  # centroids. Then subtract dislike from like for a general
  # recommendation score, and sort from most-recommended to least
  model(not-rated.t
      .build-column("like",       {(r):
        if liked.t.length() == 0: 0 else: cosine-similarity(preference, r) end })
      .build-column("dislike",    {(r):
        if disliked.t.length() == 0: 0 else: cosine-similarity(aversion, r) end })
      .build-column("recommend",  {(r): r["like"] - r["dislike"]})
      .order-by("recommend", false))
end


fun search-by-centroid(m, centroid):
  model(m.t
      .build-column("similarity", {(r): cosine-similarity(centroid, r)})
      .order-by("similarity", false))
end

fun search-by-tag(m, tag):
  matching-docs = model(
    m.t.filter({(r): string-split-all(r["TAGS"], ",").member(tag) }))
  centroid = build-centroid(matching-docs)
  search-by-centroid(m, centroid)
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
fun add-bag-cols(m :: Model, col :: String) -> Model block:
  # Step 1: convert each row's text into a normalized word list
  all-word-lists = m.t.column(col).map(lam(s): string-split-all(s, ' ') end)

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
  model(unique-words.foldl(
      lam(word, shadow t):
        t.build-column(word, lam(r):
            words = string-split-all(r[col], ' ')
            sd = list-of-words-to-sd(words)
            cases(Starter.Option) sd.get(word):
              | none => 0
              | some(shadow count) => count
            end
          end)
      end,
      m.t))
  #    .drop("DOC")
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
    raise("Cosine and angle similarity require at least 2 quantitative columns.")
  end
  # convert each row to a StringDict, and compute cosine similarity
  sd-cos-sim(row-to-dict(cols, r1), row-to-dict(cols, r2))
end

# angle-similarity-lists: converts cosine similarity to degrees (0-90°).
# 0° means the DOCs are identical; 90° means completely dissimilar.
fun angle-similarity(r1 :: Row, r2 :: Row) -> Number:
  num-exact((num-acos(cosine-similarity(r1, r2)) * 180) / 3.14159265)
end


fun compute-similarity(m :: Model, id, fn) block:
  compare-to = row-n(m.t.filter({(r): r["ID"] == id}), 0)
  fun compare-row(r): fn(r, compare-to) end
  model(m.t.build-column("similarity", compare-row))
end


song-model  = add-bag-cols(song-corpus, "DOC")
poem-model  = add-bag-cols(normalize(poem-corpus, true), "NORMALIZED")
text-model  = add-bag-cols(normalize(text-corpus, true), "NORMALIZED")

small-images = shrink-images(image-corpus)

image-model = add-bag-cols(add-color-names(add-luminance(add-entropy(small-images))), "COLOR-NAMES")



########################################################################
# Wrap DS chart functions
shadow mean   = lam(m :: Model, col): mean(m.t, col) end
shadow median = lam(m :: Model, col): median(m.t, col) end
shadow modes  = lam(m :: Model, col): modes(m.t, col) end

shadow row-n  = lam(m :: Model, index): m.t.row-n(index) end
shadow count  = lam(m :: Model, col): count(m.t, col) end
shadow stdev  = lam(m :: Model, col): stdev(m.t, col) end

shadow bar-chart = lam(m :: Model, col): bar-chart(m.t, col) end
shadow multi-bar-chart = lam(m :: Model, col1, col2):
  multi-bar-chart(m.t, col1, col2)
end
shadow stacked-bar-chart = lam(m :: Model, col1, col2):
  stacked-bar-chart(m.t, col1, col2)
end

shadow pie-chart = lam(m :: Model, col): pie-chart(m.t, col) end
shadow box-plot  = lam(m :: Model, col): box-plot(m.t, col) end
shadow dot-plot  = lam(m :: Model, ls, vs): dot-plot(m.t, ls, vs) end
shadow histogram = lam(m :: Model, ls, vs, bin-width):
  histogram(m.t, ls, vs, bin-width)
end

shadow scatter-plot = lam(m :: Model, ls :: String, xs :: String, ys :: String):
  scatter-plot(m.t, ls, xs, ys)
end
shadow image-scatter-plot = lam(m :: Model, ls :: String, xs :: String, ys :: String, fn :: (Row -> Image)):
  image-scatter-plot(m.t, ls, xs, ys, fn)
end
shadow lr-plot = lam(m :: Model, ls :: String, xs :: String, ys :: String):
  lr-plot(m.t, ls, xs, ys)
end
shadow fit-model = lam(m :: Model, ls :: String, xs :: String, ys :: String, fn):
  fit-model(m.t, ls, xs, ys, fn)
end
shadow filter = lam(m :: Model, fn :: (Row -> Boolean)) -> Model:
  model(filter(m.t, fn))
end
shadow build-column = lam(m :: Model, col :: String, fn :: (Row -> Any)) -> Model:
  model(build-column(m.t, col, fn))
end