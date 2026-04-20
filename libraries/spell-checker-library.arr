use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "core.arr")
################################################################
# Bootstrap Spell Checker Library, as of Fall 2026

provide *

import starter2024 as Starter
provide from Starter:
  * hiding(translate, filter, range, sort, sin, cos, tan)
end

provide from L: * hiding(filter, range, sort), type *, data * end

word-sheet = load-spreadsheet("1RlwxGM1oZd6VfJDwuVNxGIwznB2yGyjwfuKHdXg6Gz8")

fun get-words-from-sheet(sheet-name :: String) -> Sets.Set<String>:
  Sets.list-to-tree-set(extract all-words from
      load-table: all-words :: String
        source: word-sheet.sheet-by-name(sheet-name, true)
      end
    end)
end

WORDS-ALL  = get-words-from-sheet("All-Words")
WORDS      = get-words-from-sheet("Words")
WORDS-1000 = get-words-from-sheet("Words-1000")
WORDS-100  = get-words-from-sheet("Words-100")

var words-worklist = [SD.mutable-string-dict: ]

fun init-vars() block:
  words-worklist := [SD.mutable-string-dict: ]
end

fun register(w :: String, distance :: Number) -> Nothing:
  cases (Starter.Option) words-worklist.get-now(w):
    | none => words-worklist.set-now(w, distance)
    | some(existing-dist) =>
      when distance < existing-dist:
        words-worklist.set-now(w, distance)
      end
  end
end

all-letters-strs =
  string-explode('abcdefghijklmnopqrstuvwxyz')

fun edits1(w :: String, distance :: Number) -> Nothing:
  n = string-length(w)
  for each(i from L.range(0, n)) block:
    pre = string-substring(w, 0, i)
    c   = string-substring(w, i, i + 1)
    suf = string-substring(w, i + 1, n)
    register(pre + suf, distance)
    for each(l from all-letters-strs) block:
      register(pre + l + suf, distance)
      register(pre + l + c + suf, distance)
      register(pre + c + l + suf, distance)
    end
  end
end

fun edits2(w :: String) -> Nothing block:
  edits1(w, 1)
  e1l = words-worklist.keys-now().to-list()
  expanded = [SD.mutable-string-dict: ]
  for each(e1w from e1l):
    when expanded.get-now(e1w) == none block:
      expanded.set-now(e1w, true)
      edits1(e1w, 2)
    end
  end
end

data WordResult:
  | word-result(word :: String, edit-distance :: Number)
end

fun find-worklist-words(dict :: Sets.Set<String>, orig-len :: Number) -> List<WordResult>:
  for filter-map(e12w from words-worklist.keys-now().to-list()):
    wlen = string-length(e12w)
    if (wlen >= (orig-len - 2)) and (wlen <= (orig-len + 2)) and dict.member(e12w):
      some(word-result(e12w, words-worklist.get-value-now(e12w)))
    else:
      none
    end
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
  when string-length(s) > 7 :
    raise("The word must be 7 or fewer letters; '" + s + "' has length " + num-to-string(string-length(s)))
  end
  init-vars()
  edits2(s)
  results = find-worklist-words(dict, string-length(orig-s))
  row-list = results.map({(wr): [
      T.raw-row: {"word"; wr.word},
      {"edit-distance"; wr.edit-distance}
    ]})
  row-list.foldl({(r, t): t.add-row(r)}, table: word, edit-distance end)
end