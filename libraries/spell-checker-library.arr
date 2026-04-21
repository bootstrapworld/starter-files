use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "core.arr")
################################################################
# Bootstrap Spell Checker Library, as of Fall 2026

provide *

import starter2024 as Starter
import csv as csv
provide from Starter:
    * hiding(translate, filter, range, sort, sin, cos, tan)
end

provide from L: * hiding(filter, range, sort), type *, data * end

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

var d1-sources = [SD.mutable-string-dict: ]
var d1-results = [SD.mutable-string-dict: ]
var d2-results = [SD.mutable-string-dict: ]

fun init-vars() block:
  d1-sources := [SD.mutable-string-dict: ]
  d1-results := [SD.mutable-string-dict: ]
  d2-results := [SD.mutable-string-dict: ]
end

fun register(w :: String, distance :: Number, dict :: Sets.Set<String>) -> Nothing:
  if distance == 1 block:
    when d1-sources.get-now(w) == none:
      d1-sources.set-now(w, true)
    end
    when dict.member(w) and (d1-results.get-now(w) == none):
      d1-results.set-now(w, true)
    end
  else:
    when (d1-results.get-now(w) == none) and (d2-results.get-now(w) == none):
      when dict.member(w):
        d2-results.set-now(w, true)
      end
    end
  end
end

all-letters-strs =
  string-explode('abcdefghijklmnopqrstuvwxyz')

fun edits1(w :: String, distance :: Number, dict :: Sets.Set<String>) -> Nothing:
  n = string-length(w)
  for each(i from L.range(0, n)) block:
    pre = string-substring(w, 0, i)
    c   = string-substring(w, i, i + 1)
    suf = string-substring(w, i + 1, n)
    register(pre + suf, distance, dict)
    for each(l from all-letters-strs) block:
      register(pre + l + suf, distance, dict)
      register(pre + l + c + suf, distance, dict)
      register(pre + c + l + suf, distance, dict)
    end
  end
end

fun edits2(w :: String, dict :: Sets.Set<String>) -> Nothing block:
  edits1(w, 1, dict)
  e1l = d1-sources.keys-now().to-list()
  for each(e1w from e1l):
    edits1(e1w, 2, dict)
  end
end

data WordResult:
  | word-result(word :: String, edit-distance :: Number)
end

fun find-worklist-words() -> List<WordResult>:
  d1 = for map(w from d1-results.keys-now().to-list()): word-result(w, 1) end
  d2 = for map(w from d2-results.keys-now().to-list()): word-result(w, 2) end
  d1 + d2
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
  edits2(s, dict)
  results = find-worklist-words()
  row-list = results.map({(wr): [
        T.raw-row: {"word"; wr.word},
        {"edit-distance"; wr.edit-distance}
      ]})
  row-list.foldl({(r, t): t.add-row(r)}, table: word, edit-distance end)
end