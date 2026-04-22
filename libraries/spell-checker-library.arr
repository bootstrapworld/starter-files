use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "core.arr")
################################################################
# Bootstrap Spell Checker Library, as of Fall 2026

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

provide *

DICTIONARY-URL = "https://docs.google.com/spreadsheets/d/13vL8Tg4lJ09s9GJwTKTZ9Ne1b6wDa92nj8RUPwgNfBQ/export?format=csv&gid="
MAX-LENGTH = 11

fun get-words-from-sheet(gid :: String) -> Sets.Set<String>:
  Sets.list-to-tree-set(extract all-words from
      load-table: all-words :: String
        source: csv.csv-table-url(DICTIONARY-URL + gid, {
              header-row: true,
              infer-content: false
            })
      end
    end)
end

#WORDS-XL = get-words-from-sheet("355650150")  # 50000 words (takes a long time to load!)
WORDS-L  = get-words-from-sheet("0")          # 20000 words
WORDS-M  = get-words-from-sheet("1465800911") # 1000 words
WORDS-S  = get-words-from-sheet("1712073918") # 500 words
WORDS-XS = get-words-from-sheet("160808960")  # 100 words

# sources: all generated candidates, word -> minimum distance seen
# results: dictionary members only, word -> minimum distance seen
var sources = [SD.mutable-string-dict: ]
var results = [SD.mutable-string-dict: ]

fun init-vars() block:
  sources := [SD.mutable-string-dict: ]
  results := [SD.mutable-string-dict: ]
end

fun register(w :: String, distance :: Number, dict :: Sets.Set<String>) -> Nothing:
  cases (Starter.Option) sources.get-now(w) block:
    | some(_) => nothing  # already seen at a lower or equal distance
    | none =>
      sources.set-now(w, distance)
      when dict.member(w):
        results.set-now(w, distance)
      end
  end
end

all-letters-strs =
  string-explode('abcdefghijklmnopqrstuvwxyz')

fun edits1(w :: String, distance :: Number, dict :: Sets.Set<String>) -> Nothing:
  wlen = string-length(w)
  for each(i from L.range(0, wlen)) block:
    pre = string-substring(w, 0, i)
    c   = string-substring(w, i, i + 1)
    suf = string-substring(w, i + 1, wlen)
    register(pre + suf, distance, dict)
    for each(l from all-letters-strs) block:
      register(pre + l + suf, distance, dict)
      register(pre + l + c + suf, distance, dict)
      register(pre + c + l + suf, distance, dict)
    end
  end
end

fun editsN(w :: String, n :: Number, dict :: Sets.Set<String>) -> Nothing block:
  edits1(w, 1, dict)
  for each(level from L.range(2, n + 1)):
    prev-level-sources = sources.keys-now().to-list().filter({(src):
        sources.get-value-now(src) == (level - 1)
      })
    for each(src from prev-level-sources):
      edits1(src, level, dict)
    end
  end
end

data WordResult:
  | word-result(word :: String, edit-distance :: Number)
end

fun find-worklist-words() -> List<WordResult>:
  for map(w from results.keys-now().to-list()):
    word-result(w, results.get-value-now(w))
  end
end

fun time(thk):
  start = time-now()
  r = thk()
  stop = time-now()
  {r; stop - start}
end

fun alt-words(orig-s :: String, dict :: Sets.Set<String>) block:
  s = string-to-lower(orig-s)
  when string-length(s) > MAX-LENGTH:
    max-str = to-string(MAX-LENGTH)
    raise("The word must be " + max-str + " or fewer letters; '" + s + "' has length " + to-string(string-length(s)))
  end
  init-vars()
  editsN(s, 2, dict)
  found = find-worklist-words()
  row-list = found.map({(wr): [
        T.raw-row: {"word"; wr.word},
        {"edit-distance"; wr.edit-distance}
      ]})
  row-list.foldl({(r, t): t.add-row(r)}, table: word, edit-distance end)
end