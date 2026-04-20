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

var all-seen-words = [SD.mutable-string-dict: ]
var words-worklist = [SD.mutable-string-dict: ]

fun init-vars() block:
  all-seen-words := [SD.mutable-string-dict: ]
  words-worklist := [SD.mutable-string-dict: ]
end

fun word-mod(
    cps :: List<Number>,
    replace :: (Number -> List<Number>),
    distance :: Number)
  -> Nothing:
  mods = for map(i from L.range(0, cps.length())):
    result = split-at(i, cps)
    {this-char; suf} =
      if is-empty(result.suffix):
        {empty; empty}
      else:
        {result.suffix.first; result.suffix.rest}
      end
    result.prefix + replace(this-char) + suf
  end
  mod-words = map(string-from-code-points, mods)
  for each(w from mod-words):
    cases (Starter.Option) all-seen-words.get-now(w):
      | none =>
        cases (Starter.Option) words-worklist.get-now(w):
          | none =>
            words-worklist.set-now(w, distance)
          | some(existing-dist) =>
            when distance < existing-dist:
              words-worklist.set-now(w, distance)
            end
        end
      | some(shadow count) =>
        all-seen-words.set-now(w, 1 + count)
    end
  end
end

all-letters-cps =
  map(string-to-code-point, string-explode('abcdefghijklmnopqrstuvwxyz'))

fun edits1(w :: String, distance :: Number) -> Nothing block:
  doc: "All edits that are one edit away from `word`"
  w-cps = string-to-code-points(w)
  word-mod(w-cps, {(_): empty}, distance)

  # replace
  each({(l): word-mod(w-cps, {(_): [list: l]}, distance)}, all-letters-cps)
  # insert before
  each({(l): word-mod(w-cps, {(c): [list: l, c]}, distance)}, all-letters-cps)
  # insert after
  each({(l): word-mod(w-cps, {(c): [list: c, l]}, distance)}, all-letters-cps)

  nothing
end

fun edits2(w :: String) -> Nothing block:
  edits1(w, 1)
  e1l = words-worklist.keys-now().to-list()

  for each(e1w from e1l):
    cases (Starter.Option) all-seen-words.get-now(e1w) block:
      | none =>
        all-seen-words.set-now(e1w, 0)
        edits1(e1w, 2)
      | some(shadow count) =>
        all-seen-words.set-now(e1w, 1 + count)
    end
  end
end

data WordResult:
  | word-result(word :: String, edit-distance :: Number)
end

fun find-worklist-words(dict :: Sets.Set<String>) -> List<WordResult> block:
  valid-edits = [SD.mutable-string-dict: ]
  e12l = words-worklist.keys-now().to-list()
  for each(e12w from e12l):
    when dict.member(e12w):
      dist = words-worklist.get-value-now(e12w)
      cases (Starter.Option) valid-edits.get-now(e12w):
        | none =>
          valid-edits.set-now(e12w, dist)
        | some(existing-dist) =>
          when dist < existing-dist:
            valid-edits.set-now(e12w, dist)
          end
      end
    end
  end

  for map(w from valid-edits.keys-now().to-list()):
    word-result(w, valid-edits.get-value-now(w))
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
  when string-length(s) > 7:
    raise("The word must be 7 or fewer letters; '" + s + "' has length " + num-to-string(string-length(s)))
  end
  init-vars()
  edits2(s)
  results = find-worklist-words(dict)
  row-list = results.map({(wr): [
        T.raw-row: {"word";wr.word}, 
        {"edit-distance"; wr.edit-distance}
      ]})
  row-list.foldl({(r, t): t.add-row(r)}, table: word, edit-distance end)
end