use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")

num-words :: String -> Number
# consumes text and produces the number of words
fun num-words(txt):
  string-split-all(txt, " ").length()
end


num-sentences :: String -> Number
# consumes text and produces the number of sentences
fun num-sentences(txt):
  string-split-all(txt, ". ").length()
end

# count-syllables :: String -> Number
# consumes text, breaks it into words, then produces the
# sum of their syllables
# crude algorithm from https://stackoverflow.com/questions/49754440/count-syllables-function-scheme
fun num-syllables(txt):
  vowels = [list: "a", "e", "i", "o", "u"]
  fun syllables(lst):
    ask:
      | L.is-empty(lst) then: 0
      | vowels.member(lst.get(0)) then:
        1 + skip-vowels(lst.rest)
      | otherwise: syllables(lst.rest)
    end
  end

  fun skip-vowels(lst):
    ask:
    | L.is-empty(lst) then: syllables([list:])
      | vowels.member(lst.get(0)) then: skip-vowels(lst.rest)
      | otherwise: syllables(lst)
    end
  end
  words = string-split(txt, " ")
  words.foldl(lam(w, shadow count):
    count + syllables(string-explode(w)) end,
    0)
end

flesch-kincaid :: String -> Number
# consumes text and produces the great level according
# to Flesch-Kincaid:
# Grade = .39(words/sentences)+11.8(syllables/words)-15.59
# https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests
fun flesch-kincaid(txt):
  total-words = num-words(txt)
  total-sentences = num-sentences(txt)
  total-syllables = num-syllables(txt)
  ((0.39 * (total-words / total-sentences)) +
    (11.8 * (total-syllables / total-words))) -
  15.59
end

###########################################
# here's an example
flesch-kincaid("I found text excerpts of my own to be off by 1 to 2 grade levels, depending on whether I calculated with the formula or used the MS Word program. My best guess is that some modifications have been made since the tool was first developed by Kincaid in 1975. Maybe adjustments needed to be made because what used to be considered 11th grade material would now be more appropriate for 13th grade? Anyway, the formula in blue above seems like something you could easily enough task students with programming in Bootstrap. They can certainly use it to make comparisons of texts by different writers, and perhaps even critique its consistency with the MS Word tool. Nice talking to you today! Nancy")
