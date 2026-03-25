################################################################
# Bootstrap Bag of Words Library, as of Fall 2026

provide *

# Re-export everything from starter2024, except for functions we override
import starter2024 as Starter
include from Starter:
    * hiding(translate, filter, range, sort, sin, cos, tan)
end

import data-source as DS

image-corpus = table: tag, document
  row: "img1", image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/img1.png")
  row: "img2", image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/img2.png")
  row: "img3", image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/img3.png")
  row: "img4", image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/img4.png")
  row: "img5", image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/img5.png")
  row: "img6", image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/img6.png")
  row: "img7", image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/img7.png")
  row: "img8", image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/img8.png")
  row: "img9", image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/img9.png")
end

mystery-image = image-url("https://bootstrapworld.org/materials/fall2025/en-us/lessons/ai-intro/images/small-imgs/mystery.png")


poem-corpus = table: tag, document
  row: "Document A", "The sun is good."
  row: "Document B", "The sand was white."
  row: "Document C", "The sea is there."
  row: "Document D", "The sun is on the sea."
  row: "Document E", "I saw the sun on the sand."
  row: "Document F", "The sea was at the sand."
  row: "Document G", "The sun was on the sea and the sand."
  row: "Document H", "I had the sun and the sea and the sand."
  row: "Document I", "When the sun is up, the sea is on the sand."
end
    
mystery-poem = "The sun is big, but the sea is all"

song-corpus = table: tag, document
  row: "Song A", "🫰 👏 🫰 👏 🫰 🫰 🫰 🫰 🫰 🫰 👏 🫰 🫰 👏 👏 👏 🫰 🫰 👏"
  row: "Song B", "🫰 🫰 🫰 👏 🫰 👏 🫰 👏 🫰 👏"
  row: "Song C", "👏 🫰 🫰 🫰 🫰 🫰 🫰 👏 🫰 🫰 👏 🫰 👏 👏 🫰"
  row: "Song D", "🫰 👏 🫰 🫰 👏 🫰 🫰 👏 👏 🫰 👏 🫰 👏 👏 👏 🫰 🫰"
  row: "Song E", "👏 🫰 👏 🫰 🫰 🫰 👏 🫰 🫰 🫰 🫰 👏 🫰"
  row: "Song F", "👏 👏 👏 🫰 🫰 👏 👏 🫰 👏 🫰 👏 🫰 🫰 👏 👏 🫰 🫰 👏"
  row: "Song G", "🫰 🫰 🫰 🫰 👏 👏 👏 🫰 🫰 👏 🫰 👏 👏 👏 👏"
  row: "Song H", "👏 👏 👏 👏 👏 👏 👏 👏 👏 👏 👏 👏 👏 👏 👏 👏 👏 👏"
  row: "Song I", "🫰 🫰 🫰 🫰 🫰 🫰 🫰 🫰 🫰 🫰 🫰 🫰 🫰 🫰 🫰 🫰"
end

mystery-song = "👏 👏 🫰 🫰 👏 🫰 👏 🫰 🫰 🫰 🫰 🫰 🫰 🫰 👏 👏 🫰"


text-corpus = table: tag, document
  # from https://en.wikipedia.org/wiki/American_badger
  row: "badger", "The American badger is a North American badger similar in appearance to the European badger, although not closely related. It is found in the western, central, and northeastern United States, northern Mexico, and south-central Canada to certain areas of southwestern British Columbia. The American badger's habitat is typified by open grasslands with available prey (such as mice, squirrels, and groundhogs)."
    # from https://en.wikipedia.org/wiki/Blue_whale
  row: "blue whale", "The blue whale is a marine mammal and a baleen whale. Reaching a maximum confirmed length of 29.9 m and weighing up to 199 tons, it is the largest animal known ever to have existed. The blue whale's long and slender body can be of various shades of greyish-blue on its upper surface and somewhat lighter underneath."
    # from https://en.wikipedia.org/wiki/Chimpanzee
  row: "chimpanzee", "The chimpanzee lives in groups that range in size from 15 to 150 members, although individuals travel and forage in much smaller groups during the day. The species lives in a strict male-dominated hierarchy, where disputes are generally settled without the need for violence. Nearly all chimpanzee populations have been recorded using tools, modifying sticks, rocks, grass and leaves and using them for hunting and acquiring honey, termites, ants, nuts and water."
    # from https://en.wikipedia.org/wiki/Elephants_in_Thailand
  row: "elephant", "The elephant has been a contributor to Thai society and its icon for many centuries. The elephant has had a considerable impact on Thai culture. The Thai elephant is the official national animal of Thailand. The elephant found in Thailand is the Indian elephant, a subspecies of the Asian elephant."
    # from https://en.wikipedia.org/wiki/Giraffe
  row: "giraffe", "The giraffe's distinguishing characteristics are its extremely long neck and legs, horn-like ossicones, and spotted coat patterns. It is classified under the family Giraffidae, along with its closest extant relative, the okapi. Its scattered range extends from Chad in the north to South Africa in the south and from Niger in the west to Somalia in the east."
    # from https://en.wikipedia.org/wiki/Hamster
  row: "hamster", "Hamsters feed primarily on seeds, fruits, vegetation, and occasionally burrowing insects. In the wild, they are crepuscular: they forage during the twilight hours. In captivity, however, they are known to live a conventionally nocturnal lifestyle, waking around sundown to feed and exercise. Physically, they are stout-bodied with distinguishing features that include elongated cheek pouches extending to their shoulders, which they use to carry food back to their burrows, as well as a short tail and fur-covered feet."
    # from https://en.wikipedia.org/wiki/Manatee
  row: "manatee", "Manatees are herbivores and eat over 60 different freshwater and saltwater plants. Manatees inhabit the shallow, marshy coastal areas and rivers of the Caribbean Sea, the Gulf of Mexico, the Amazon basin, and West Africa. The main causes of death for manatees are human-related issues, such as habitat destruction and human objects."
    # from https://en.wikipedia.org/wiki/Polar_bear
  row: "polar bear", "The polar bear is a large bear native to the Arctic and nearby areas. It is closely related to the brown bear, and the two species can interbreed. The polar bear is the largest extant species of bear and land carnivore, with adult males weighing 300-800 kg. The polar bear is white- or yellowish-furred with black skin and a thick layer of fat."
    # from https://en.wikipedia.org/wiki/Rhinoceros
  row: "rhino", "Rhinoceroses are some of the largest remaining megafauna: all weigh over half a tonne in adulthood. They have a herbivorous diet, small brains 400-600 g for mammals of their size, one or two horns, and a thick 1.5-5 cm, protective skin formed from layers of collagen positioned in a lattice structure. They generally eat leafy material."
    # from https://en.wikipedia.org/wiki/Snail
  row: "snail", "Snails can be found in a very wide range of environments, including ditches, deserts, and the abyssal depths of the sea. Although land snails may be more familiar to laymen, marine snails constitute the majority of snail species, and have much greater diversity and a greater biomass. Numerous kinds of snail can also be found in fresh water."
end

# from https://en.wikipedia.org/wiki/Okapi
mystery-text = "The okapi is classified under the family Giraffidae, along with its closest extant relative, the giraffe. Its distinguishing characteristics are its long neck, and large, flexible ears. Male okapis have horn-like protuberances called ossicones. "


##############################################################################################################
# Image Helpers

# image-to-color-names :: Table -> Table
# Replaces each image with a string of comma-separated color names ("red", "green",
# or "blue") representing the dominant channel of each non-transparent pixel
fun image-to-color-names(t) -> Table block:
  fun dominant-color(pixel) -> String:
    if (pixel.red >= pixel.green) and (pixel.red >= pixel.blue): "red"
    else if (pixel.green >= pixel.red) and (pixel.green >= pixel.blue): "green"
    else: "blue"
    end
  end
  transform-column(t, "document", lam(img): image-to-color-list(img)
        .filter(lam(pixel): pixel.alpha > 0 end)
        .map(dominant-color)
        .join-str(" ")
    end)
end


# shrink-images :: Table -> Table
fun shrink-images(t):
  transform-column(t, "document", lam(img): scale(0.5, img) end)
end

fun img-luminance(img):
  Stats.mean(image-to-color-list(img).map(luminance))
end

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

# Main function: compute entropy of an image
fun img-entropy(img) -> Number:
  pixels = image-to-color-list(img)
  total = pixels.length()
  freq = build-freq(pixels, [SD.string-dict:])
  entropy-sum(freq.keys().to-list(), freq, total, 0)
end

fun img-color(img) -> Number:
  fun pixel-color(p): (p.red * sqr(256)) + (p.green * 256) + p.blue end
  Stats.mean(image-to-color-list(img).map(pixel-color))
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

# normalize the "document" column by:
# 1) massaging the string (lowercase + remove punctuation)
# 2) splitting on spaces
# 3) filtering out any empty strings
fun normalize(t) -> Table block:
  fun is-non-empty-string(w :: String) -> Boolean:  w <> '' end
  transform-column(t, "document", 
    lam(s): string-split-all(massage-string(string-to-lower(s)), ' ')
        .filter(is-non-empty-string)
        .join-str(' ') 
    end)
end

# A standard list of English stop words (common words like "the", "and",
# "a" etc.) that carry little meaning and can be ignored when comparing
# documents for similarity. From Fox (1990).
standard-stop-words = [list: "the", "and", "a", "that", "was", "for", "with", "not", "on", "at", "i", "had", "are", "or", "an", "they", "one", "would", "all", "there", "their", "him", "has", "when", "if", "out", "what", "up", "about", "into", "can", "other", "some", "time", "two", "then", "do", "now", "such", "man", "our", "even", "made", "after", "many", "must", "years", "much", "your", "down", "should", "of", "to", "in", "is", "he", "it", "as", "his", "be", "by", "this", "but", "from", "have", "you", "which", "were", "her", "she", "will", "we", "been", "who", "more", "no", "so", "said", "its", "than", "them", "only", "new", "could", "these", "may", "first", "any", "my", "like", "over", "me", "most", "also", "did", "before", "through", "where", "back", "way", "well", "because", "each", "people", "state", "mr", "how", "make", "still", "own", "work", "long", "both", "under", "never", "same", "while", "last", "might", "day", "since", "come", "great", "three", "go", "few", "use", "without", "place", "old", "small", "home", "went", "once", "school", "every", "united", "number", "does", "away", "water", "fact", "though", "enough", "almost", "took", "night", "system", "general", "better", "why", "end", "find", "asked", "going", "knew", "toward", "just", "those", "too", "world", "very", "good", "see", "men", "here", "get", "between", "year", "another", "being", "life", "know", "us", "off", "against", "came", "right", "states", "take", "himself", "during", "again", "around", "however", "mrs", "thought", "part", "high", "upon", "say", "used", "war", "until", "always", "something", "public", "put", "think", "head", "far", "hand", "set", "nothing", "point", "house", "later", "eyes", "next", "program", "give", "white", "room", "social", "young", "present", "order", "second", "possible", "light", "face", "important", "among", "early", "need", "within", "business", "felt", "best", "ever", "least", "got", "mind", "want", "others", "although", "open", "area", "done", "certain", "door", "different", "sense", "help", "perhaps", "group", "side", "several", "let", "national", "given", "rather", "per", "often", "god", "things", "large", "big", "become", "case", "along", "four", "power", "saw", "less", "thing", "today", "interest", "turned", "members", "family", "problem", "kind", "began", "thus", "seemed", "whole", "itself"]

# remove-stop-words filters a list of words, removing any that appear
# in the standard stop words list
fun remove-stop-words(t) -> Table:
  transform-column(t, "document", 
    lam(s): string-split-all(s, ' ')
        .filter(lam(w): not(standard-stop-words.member(w)) end)
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
      { current: new-current, max-seen: num-max(new-current, acc.max-seen) }
    else:
      {       current: 0,           max-seen: acc.max-seen                 }
    end
  end

  final-stats.max-seen
where:
  longest-streak("sun sea sun sun sand", "sun") is 2
  longest-streak("sea sea sea", "sea") is 3
  longest-streak("sand sun sea", "cyan") is 0
  longest-streak("sun sun sand sun sun sun", "sun") is 3
end

fun longest-snaps(s): longest-streak(s, "🫰") end
fun longest-clap(s):  longest-streak(s, "👏") end
fun longest-stomp(s): longest-streak(s, "🦶") end


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
  all-word-lists = t.column("document").map(lam(s): string-split-all(s, ' ') end)

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
          sd = list-of-words-to-sd(string-split-all(r["document"], ' '))
          cases(Starter.Option) sd.get(word):
            | none => 0
            | some(shadow count) => count
          end
        end)
    end,
    t)
    .drop("document")
end

fun add-col(t :: Table, name :: String, fn :: (Row -> Number)): 
  build-column(t, name, lam(r): fn(r["document"]) end)
end


##############################################################################################################
# Similarity Tools
# All of these methods of comparison produce a numerical value


# dot-product computes the dot product of two word-frequency StringDicts.
# For each word that appears in both dicts, it multiplies the two
# frequencies and sums the results. Words that only appear in one dict
# contribute nothing (implicitly treated as 0 frequency in the other).
fun dot-product(sd1 :: SD.StringDict<Number>, sd2 :: SD.StringDict<Number>) -> Number block:
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
fun row-to-dict(cols :: List<String>, r :: Row) -> SD.StringDict<Number>:
  cases (List) cols:
    | empty => [SD.string-dict:]
    | link(col, rest) =>
      row-to-dict(rest, r).set(col, r[col])
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

# simple-similarity: true iff the two documents are identical
# (same words, same order, same frequency)
fun simple-similarity(r1 :: Row, r2 :: Row) -> Number block:
  cols = r1.get-column-names()
  when not(member(cols, "document")):
    raise("Simple similarity requires that all rows have a 'document' column")
  end
  if (r1["document"] == r2["document"]): 1 else: 0 end 
end

# bag-similarity: true iff the two bags contain the same words
# with the same frequencies, regardless of order
fun bag-similarity(r1 :: Row, r2 :: Row) -> Number block:
  cols = r1.get-column-names()
  when cols.length() == 0:
    raise("Bag similarity ignores the 'tag' and 'document' columns, but no other columns were found")
  end
  sd1 = row-to-dict(cols, r1)
  sd2 = row-to-dict(cols, r2)
  # just compare the BOWs
  if (sd1 == sd2): 1 else: 0 end
end


# cosine-similarity-lists: returns a number from 0 to 1 measuring how
# similar the two word-frequency vectors are. 1 = identical bags,
# 0 = no words in common. Uses the standard cosine similarity formula:
#   cos(θ) = (A · B) / (|A| * |B|)
fun cosine-similarity(r1 :: Row, r2 :: Row) -> Number block:

  # error-checking
  cols = r1.get-column-names().filter({(c): (c <> "tag") and (c <> "document")})
  when cols.length() < 2:
    raise("Cosine and angle similarity require at least two columns to work with (not counting any existing 'tag' and 'document' columns)")
  end

  # get our bags
  sd1 = row-to-dict(cols, r1)
  sd2 = row-to-dict(cols, r2)
  
  # shortcut for identical bags
  when sd1 == sd2: 1 end
  
  # if the magnitude of the products is 0, return 0 with a warning
  magnitude-product = num-exact(
    sqrt(dot-product(sd1, sd1)) * sqrt(dot-product(sd2, sd2))
    )
  if magnitude-product == 0 block: 
    display("Warning: One or more of the vectors is zero. Is this expected?")
    0 
  else:
    num-exact(dot-product(sd1, sd2) / magnitude-product)
  end
end

# angle-similarity-lists: converts cosine similarity to degrees (0-90°).
# 0° means the documents are identical; 90° means completely dissimilar.
fun angle-similarity(r1 :: Row, r2 :: Row) -> Number:
  num-exact((num-acos(cosine-similarity(r1, r2)) * 180) / 3.14159265)
end


fun compute-similarity(t :: Table, fn) block:
  compare-to = row-n(t, 0)
  fun compare-row(r): fn(r, compare-to) end
  build-column(t, "similarity", compare-row)
end

fun add-doc(t, tag, doc): 
  row = [T.raw-row: {"tag"; tag}, {"document"; doc}]
  t.empty().add-row(row).stack(t) 
end



image-bag = convert-to-bag(image-to-color-names(shrink-images(image-corpus)))
song-bag  = convert-to-bag(song-corpus)
poem-bag  = convert-to-bag(remove-stop-words(normalize(poem-corpus)))
text-bag  = convert-to-bag(remove-stop-words(normalize(text-corpus)))