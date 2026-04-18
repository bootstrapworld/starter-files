use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr")
################################################################
# Bootstrap AI Library, as of Fall 2026
provide *

# re-export every symbol from Core
import url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr") as Core
import csv as csv
provide from Core:
    * hiding(
    mean,
    median,
    modes,
    row-n,
    filter,
    build-column,
    split-and-reduce,
    count,
    stdev,
    bar-chart,
    multi-bar-chart,
    stacked-bar-chart,
    pie-chart,
    box-plot,
    dot-plot,
    histogram,
    scatter-plot,
    image-scatter-plot,
    lr-plot,
    fit-model
    ),
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

# 1) massaging the string (lowercase + remove punctuation)
# 2) splitting on spaces
# 3) filtering out any empty strings
fun text-clean(txt :: String, remove-stops :: Boolean) -> String block:
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

  string-split-all(massage-string(txt), ' ')
    .filter(is-non-empty-string)
    .filter({(w):
      if remove-stops: not(stop-words.member(w))
      else: true
      end})
    .join-str(' ')
end

#######################################################################
# Wrap model methods as functions
fun add-luminance(m): m.add-luminance() end
fun add-entropy(m): m.add-entropy() end
fun add-vertical-symmetry(m): m.add-vertical-symmetry() end
fun add-horizontal-symmetry(m): m.add-horizontal-symmetry() end
fun add-color-names(m): m.add-color-names() end

fun add-word-count(m, col): m.add-word-count(col) end
fun add-sentence-count(m, col): m.add-sentence-count(col) end
fun add-grade(m, col): m.add-grade(col) end
fun add-cleaned(m, remove-stop): m.add-cleaned(remove-stop) end
fun add-longest-streak(m, col, target): m.add-longest-streak(col, target) end
fun add-bag-cols(m, col): m.add-bag-cols(col) end


########################################################################
# Model Functions and Structures
# We want some custom rendering, so we need to define our own datatype
# This can also be extended later, should we use a StringDict for BOW

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


# add a DOC to the model
fun add-doc(m :: Model, id :: String, doc, rating :: String, tags :: String):
  m.add-doc(id, doc, rating, tags)
end

# given a model and reverse-order pipeline, apply all the
# function calls to the model in-order
fun replay-pipeline(m, pipeline):
  for foldr(shadow m from m, op from pipeline) block:
    args = op.args
    f = op.f
    #display(op.name + "(" + push(args,"m").map(to-string).join-str(", ") + ")")
    if      args.length() == 0: f(m)
    else if args.length() == 1: f(m, args.get(0))
    else if args.length() == 2: f(m, args.get(0), args.get(1))
    else: raise(Err.message-exception(args.length() + " were specified in the pipeline for " + op.name))
    end
  end
end

# given a model, return the table, with all the added columns stripped
fun get-original-table(m :: Model) -> Table:
  for fold(t from m.t, col from m.t.column-names()):
    if restricted-cols.member(col): t
    else: t.drop(col)
    end
  end
end


data function-application:
  | call(f, name :: String, args:: List)
end

MAX-DOC-LEN = 51
data Model:
  | model(t :: Table, pipeline :: List) with:
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
    end,

    # image methods
    method add-luminance(self):
      model(self.t.build-column("luminance", {(r): image-luminance(r["DOC"])}),
        push(self.pipeline, call(add-luminance, "add-luminance",  [list:])))
    end,
    method add-entropy(self):
      model(self.t.build-column("entropy", {(r): image-entropy(r["DOC"])}),
        push(self.pipeline, call(add-entropy, "add-entropy", [list:])))
    end,
    method add-vertical-symmetry(self):
      model(self.t.build-column("vertical-symmetry", {(r): 
              rounded-exact(image-symmetry-vertical(r["DOC"]))
          }),
        push(self.pipeline, call(add-vertical-symmetry, "add-vertical-symmetry", [list:])))
    end,
    method add-horizontal-symmetry(self):
      model(self.t.build-column("horizontal-symmetry", {(r): 
            rounded-exact(image-symmetry-horizontal(r["DOC"]))
          }),
        push(self.pipeline, call(add-vertical-symmetry, "add-vertical-symmetry", [list:])))
    end,
    method add-color-names(self):
      model(self.t.build-column("COLOR-NAMES", {(r): image-color-names(r["DOC"])}),
        push(self.pipeline, call(add-color-names, "add-color-names", [list:])))
    end,

    # text methods
    method add-cleaned(self, remove-stop :: Boolean):
      model(self.t.build-column("CLEANED", {(r): text-clean(r["DOC"], remove-stop)}),
        push(self.pipeline, call(add-cleaned, "add-cleaned", [list: remove-stop])))
    end,
    method add-word-count(self, col :: String):
      model(self.t.build-column("WORD-COUNT", {(r): num-words(r[col])}),
        push(self.pipeline, call(add-word-count, "add-word-count", [list: col])))
    end,
    method add-sentence-count(self, col :: String):
      model(self.t.build-column(self, "SENTENCE-COUNT", {(r): num-sentences(r[col])}),
        push(self.pipeline, call(add-sentence-count, "add-sentence-count", [list: col])))
    end,
    method add-grade(self, col :: String):
      model(self.t.build-column("GRADE", {(r): text-grade(r[col])}),
        push(self.pipeline, call(add-grade, "add-grade", [list: col])))
    end,
    method add-longest-streak(self, col :: String, target :: String):
      model(self.t.build-column("LONGEST" + target, {(r): text-streak(r[col], target)}),
        push(self.pipeline, call(add-longest-streak, "add-longest-streak", [list: col, target])))
    end,

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
    method add-bag-cols(self, col :: String) -> Model block:
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
      all-word-lists = self.t.column(col).map(lam(s): string-split-all(s, ' ') end)

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
      model(unique-words.foldl(
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
          self.t),
        push(self.pipeline, call(add-bag-cols, "add-bag-cols", [list: col])))
    end,

    # adding a document with a rating and tags
    method add-doc(self, id :: String, doc, rating :: String, tags :: String):
      # get the original table without all added columns
      og-table = get-original-table(self)
      # add the doc to our bare table as a new row
      og-table-with-doc = og-table.add-row(
        [T.raw-row: {"ID";id}, {"DOC";doc}, {"RATING";rating}, {"TAGS";tags}])
      # replay all the operations
      replay-pipeline(make-model(og-table-with-doc), self.pipeline)
    end,

    method normalize(self):
      cols = get-unrestricted-cols(self.t.row-n(0))

      normed-t = 
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
      model(
        normed-t, 
        push(self.pipeline, call(normalize, "normalize", [list: ])))
    end
end

# fake constructor that builds a model and starts with an empty pipeline
fun make-model(t:: Table): model(t, empty) end

# a doc-mutating function
fun shrink-images(m):
  model(m.t.transform-column("DOC", shrink-image), m.pipeline)
end

# a table-normalizing function
fun normalize(m): m.normalize() end

########################################################################
# Wrap DS chart functions
shadow mean   = lam(m :: Model, col): mean(m.t, col) end
shadow median = lam(m :: Model, col): median(m.t, col) end
shadow modes  = lam(m :: Model, col): modes(m.t, col) end

shadow row-n  = lam(m :: Model, index): m.t.row-n(index) end
shadow filter = lam(m :: Model, fn :: (Row -> Boolean)) -> Model:
  model(filter(m.t, fn), m.pipeline)
end
shadow build-column = lam(m :: Model, col :: String, fn :: (Row -> Any)) -> Model:
  model(build-column(m.t, col, fn), m.pipeline)
end

shadow split-and-reduce = lam(
    m :: Model,
    col-to-split :: String,
    col-to-reduce :: String,
    reducer :: (Table, String -> Any)
    ) -> Table block:
  fun wrapped-reducer(r):
    cases(Eth.Either) run-task(lam():
            reducer(make-model(r["subtable"]), col-to-reduce)
          end):
      | left(v) => v
      | right(v) => 
        base = "An error occurred when trying to use your reducer on one of your subtables: "
        if Err.is-arity-mismatch(exn-unwrap(v)):
          raise(Err.message-exception(base + "Are you sure it consumes *only* a valid Table and column name?)"))
        else:
          raise(Err.message-exception(base + to-string(exn-unwrap(v))))
        end
    end
  end
  group(m.t, col-to-split)
    .build-column("result", wrapped-reducer)
    .drop("subtable")
end


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


animals-url = "https://docs.google.com/spreadsheets/d/1VeR2_bhpLvnRUZslmCAcSRKfZWs_5RNVujtZgEl6umA/export?format=csv"

testModel = make-model(
  load-table: name, species, sex, age, fixed, legs, pounds, weeks
    source: csv.csv-table-url(animals-url, {
          header-row: true,
          infer-content: true
        })
  end)
split = group(testModel.t, "species")
#split-and-reduce(testModel, "species", "pounds", box-plot)
###################################################################################
# Song-Specific Helpers

fun add-longest-snap(m):
  make-model(m.t.build-column("longest 🫰", lam(r): text-streak(r["DOC"], "🫰") end))
end
fun add-longest-clap(m):
  make-model(m.t.build-column("longest 👏", lam(r): text-streak(r["DOC"], "👏") end))
end
fun add-longest-stomp(m):
  make-model(m.t.build-column("longest 🦶", lam(r): text-streak(r["DOC"], "🦶") end))
end



###################################################################################
# Ratings, Recommendations, and Search

# Given a table, recursively build the centroid as a StringDict
# by averaging each non-restricted column. Use exactnum to allow
# for easy comparison
fun build-centroid(m :: Model, name) -> Row:
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

_centroid-test = make-model(table: x, y row: 2, 1 row: 4, 5 end)
examples:
  build-centroid(_centroid-test, "test") is
  [T.raw-row: {"ID";"test CENTROID"},{"DOC";""}, {"RATING";""}, {"TAGS";""},{"x";3},{"y";3}]
end

fun likes(m):    make-model(m.t.filter({(r): r["RATING"] == "like"    })) end
fun dislikes(m): make-model(m.t.filter({(r): r["RATING"] == "dislike" })) end
fun unrated(m):  make-model(m.t.filter({(r): r["RATING"] == "-"       })) end

fun find-by-tag(m, t): filter(m, {(r): string-contains(r["TAGS"], t) }) end


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
    raise(Err.message-exception("No recommendations could be computed without at least one RATING"))
  end

  # compute the centroids
  preference = build-centroid(liked, "likes")
  aversion   = build-centroid(disliked, "dislikes")

  # for every unlabeled DOC, compute the similarity from both
  # centroids. Then subtract dislike from like for a general
  # recommendation score, and sort from most-recommended to least
  model(
    not-rated.t
      .build-column("like",       {(r):
        if liked.t.length() == 0: 0 else: cosine-similarity(preference, r) end })
      .build-column("dislike",    {(r):
        if disliked.t.length() == 0: 0 else: cosine-similarity(aversion, r) end })
      .build-column("STRENGTH",  {(r): r["like"] - r["dislike"]})
      .order-by("STRENGTH", false)
      .drop("like")
      .drop("dislike"),
    m.pipeline)
end

# given a row, return a sorted table in cosine-similarity order
fun match-row(m, row):
  make-model(m.t
      .build-column("SIMILARITY to " + row["ID"], {(r): cosine-similarity(row, r)})
      .order-by("SIMILARITY to " + row["ID"], false))
end

# build a centroid for every row w/this tag, then use that to match-row
fun search-by-tag(m, tag):
  matching-docs = filter(m, 
    {(r): string-split-all(r["TAGS"], ",").member(tag) })
  centroid = build-centroid(matching-docs, tag)
  match-row(m, centroid)
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
fun compute-similarity(m :: Model, id, fn) block:
  compare-to = m.t.filter({(r): r["ID"] == id}).row-n(0)
  fun compare-row(r): fn(r, compare-to) end
  model(m.t.build-column("SIMILARITY", compare-row))
end

#|
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

# Given a set of points and a number N of clusters, group them into a list of N intervals
fun k-means-clustering(points :: List<Number>, n-clusters :: Number) -> List<{Number; Number}>:
  fun run-iterations(centroids, gas):
    assignments = points.map(lam(v): {val: v, center: find-closest(v, centroids)} end)
    new-centroids = centroids.map(lam(c):
        shadow group = assignments.filter(lam(a): a.center == c end).map(lam(a): a.val end)
      if group.length() > 0:
        group.foldl(lam(acc, v): acc + v end, 0) / group.length()
      else:
        c
      end
    end)
    if (new-centroids == centroids) or (gas <= 0): centroids
    else: run-iterations(new-centroids, gas - 1)
    end
  end

  final-centers = Sets.list-to-list-set(run-iterations(points.take(n-clusters), 10)).to-list()

  final-centers
    .map(lam(c):
      cluster = points.filter(lam(v): find-closest(v, final-centers) == c end).sort()
      {cluster.get(0); cluster.last()}
    end)
    .sort-by({(a, b): a.{0} < b.{0}}, {(a, b): a == b})

where:
  k-means-clustering([list: 1, 10, 2, 11], 2) is [list: {1; 2}, {10; 11}]
end

# Given n intervals, returns the n-1 midpoints between each adjacent pair
fun get-boundary-thresholds(intervals :: List<{Number; Number}>) -> List<Number>:
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

# Given a table, partition it by clustering col into n-clusters groups
fun cluster-by-fn(t :: Table, col :: String, n-clusters :: Number, clustering-fn):
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


data DecisionTree:
  | leaf(label :: String)
  | quant-node(
      col :: String,
      threshold :: Number,
      less-than :: DecisionTree,
      greater-than :: DecisionTree)
  | cat-node(
      col :: String,
      val :: String,
      is-val :: DecisionTree,
      is-not-val :: DecisionTree)
  sharing:
    method classify(self, r :: Row) -> String:
      cases(DecisionTree) self:
        | leaf(lbl) => lbl
        | quant-node(col, threshold, left, right) =>
          if r[col] < threshold: left.classify(r)
          else: right.classify(r)
          end
        | cat-node(col, v, is-val, is-not-val) =>
          if r[col] == v: is-val.classify(r)
          else: is-not-val.classify(r)
          end
      end
    end,

    method _output(self) block:
      fun prefix-lines(lines, first-prefix, cont-prefix):
        cases(List) lines:
          | empty => empty
          | link(first, rest) =>
            link(first-prefix + first, rest.map(lam(l): cont-prefix + l end))
        end
      end

      fun to-lines(tree :: DecisionTree) -> List<String>:
        cases(DecisionTree) tree:
          | leaf(lbl) => [list: "→ " + lbl]
          | quant-node(col, threshold, less-than, greater-than) =>
            header   = col + " < " + easy-num-repr(threshold, 8) + "?"
            yes-lines = prefix-lines(to-lines(less-than),    "├── ", "│   ")
            no-lines  = prefix-lines(to-lines(greater-than), "└── ", "    ")
            [list: header] + yes-lines + no-lines
          | cat-node(col, v, is-val, is-not-val) =>
            header    = col + " == " + v + "?"
            yes-lines = prefix-lines(to-lines(is-val),     "├── ", "│   ")
            no-lines  = prefix-lines(to-lines(is-not-val), "└── ", "    ")
            [list: header] + yes-lines + no-lines
        end
      end

      print(to-lines(self).join-str("\n"))
      vs-value(circle(1, "solid", "transparent"))
    end
end

# fraction of rows that don't match (0 = perfection)
fun get-error-rate(t :: Table, label-col :: String) -> Number:
  total = t.length()
  if total == 0: 0
  else:
    majority = most-common(t, label-col)
    t.filter-by(label-col, lam(s): s <> majority end).length() / total
  end
end

# Total misclassifications across low and high, weighted by table size
fun weighted-error(low :: Table, high :: Table, label-col :: String) -> Number:
  (get-error-rate(low, label-col) * low.length())
    + (get-error-rate(high, label-col) * high.length())
end

data SplitInfo:
  | quant-split(col :: String, threshold :: Number, low :: Table, high :: Table, err :: Number)
  | cat-split(col :: String, val :: String, yes :: Table, no :: Table, err :: Number)
end

fun split-err(s :: SplitInfo) -> Number:
  cases(SplitInfo) s:
    | quant-split(_, _, _, _, e) => e
    | cat-split(_, _, _, _, e)   => e
  end
end

# find the best quantitative column and threshold on which to split
fun find-best-quant-split(t :: Table, col :: String, label-col :: String) -> Option<SplitInfo>:
  thresholds = get-boundary-thresholds(k-means-clustering(t.get-column(col), 2))
  if thresholds.length() == 0: none
  else:
    threshold = thresholds.get(0)
    low  = t.filter-by(col, lam(v): v < threshold end)
    high = t.filter-by(col, lam(v): v >= threshold end)
    if (low.length() == 0) or (high.length() == 0): none
    else:
      some(quant-split(col, threshold, low, high, weighted-error(low, high, label-col)))
    end
  end
end

# find the best categorical column and value on which to split
fun find-best-cat-split(t :: Table, col :: String, label-col :: String) -> Option<SplitInfo>:
  possible-values = L.distinct(t.get-column(col))
  best = possible-values.foldl(lam(v, best-so-far):
    yes-t = t.filter-by(col, lam(val): val == v end)
    no-t  = t.filter-by(col, lam(val): val <> v end)
    if (yes-t.length() == 0) or (no-t.length() == 0): best-so-far
    else:
      err = weighted-error(yes-t, no-t, label-col)
      candidate = some(cat-split(col, to-string(v), yes-t, no-t, err))
      cases(Option) best-so-far:
        | none    => candidate
        | some(b) => if err < split-err(b): candidate else: best-so-far end
      end
    end
  end, none)
  best
end

# Try every column, and choose the split that minimizes weighted error
fun find-best-split(t :: Table, label-col :: String, cols :: List<String>) -> Option<SplitInfo>:
  current-err = get-error-rate(t, label-col) * t.length()
  cols.foldl(lam(col, best-so-far):
    first-val = t.row-n(0)[col]
    candidate =
      if is-number(first-val): find-best-quant-split(t, col, label-col)
      else:                    find-best-cat-split(t, col, label-col)
      end
    cases(Option) candidate:
      | none => best-so-far
      | some(c) =>
        # Only accept if this split is strictly better than doing nothing
        if split-err(c) >= current-err: best-so-far
        else:
          cases(Option) best-so-far:
            | none    => candidate
            | some(b) => if split-err(c) < split-err(b): candidate else: best-so-far end
          end
        end
    end
  end, none)
end

fun build-tree(t :: Table, label-col :: String, cols :: List<String>) -> DecisionTree:
  unique-labels = L.distinct(t.get-column(label-col))
  if (unique-labels.length() <= 1) or (cols.length() == 0) or (t.length() == 0):
    leaf(most-common(t, label-col))
  else:
    cases(Option) find-best-split(t, label-col, cols):
      | none => leaf(most-common(t, label-col))
      | some(s) =>
        cases(SplitInfo) s:
          | quant-split(col, threshold, low, high, _) =>
            quant-node(col, threshold,
              build-tree(low,  label-col, cols),
              build-tree(high, label-col, cols))
          | cat-split(col, v, yes-t, no-t, _) =>
            cat-node(col, v,
              build-tree(yes-t, label-col, cols),
              build-tree(no-t,  label-col, cols))
        end
    end
  end
end

# Returns the most frequently-occuring value in a column to use as a prediction
fun most-common(t :: Table, col :: String) -> String:
  vals = t.get-column(col)
  if vals.length() == 0: "unknown"
  else:
    counts = vals.foldl(lam(v, acc):
      key = to-string(v)
      cases(Option) acc.get(key):
        | none    => acc.set(key, 1)
        | some(n) => acc.set(key, n + 1)
      end
      end, [SD.string-dict: ])
    vals.foldl(lam(best, v):
      if counts.get-value(to-string(v)) > counts.get-value(to-string(best)): v
      else: best
      end
    end, vals.first)
  end
end

fun classify(t :: Table, col :: String, classifier :: DecisionTree) block:
  pred = build-column(t, "predicted " + col, classifier.classify)
  og = Sets.list-to-list-set(pred.column(col))
  predicted = Sets.list-to-list-set(pred.column("predicted " + col))

  # loose checking to make sure the col and classifier output match
  when predicted.any({(p): not(og.member(p))}):
    raise(Err.message-exception("The predictions returned from this classifier do not match the values in the '" + col + "' column"))
  end

  pred
end

# Produces a table comparing actual values from 'col' to predictions
fun confusion-matrix(t :: Table, col :: String, classifier :: DecisionTree) -> Table:
  labels = L.distinct(t.get-column(col)).sort()
  fun count-match(actual-val, predicted-val):
    t.filter-by(col, lam(r): r == actual-val end)
      .filter(lam(r): classifier.classify(r) == predicted-val end)
      .length()
  end
  matrix-rows = labels.map(lam(lbl):
    contents = L.link({col; lbl}, labels.map(lam(pred):
      {"predicted-" + pred; count-match(lbl, pred)}
    end))
    T.raw-row.make(raw-array-from-list(contents))
  end)
  T.table-from-rows.make(raw-array-from-list(matrix-rows))
end