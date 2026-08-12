use context starter2024

provide: 
  *,
  type Posn,
  type TaggedFunction,
  module Eth,
  module Err,
  module Sets,
  module T,
  module SD,
  module R,
  module L,
  module Stats,
  module Math
end

# export every symbol from starter2024 except for those we override
import starter2024 as Starter
provide from Starter:
    * hiding(translate, filter, range, sort, sin, cos, tan)
end

include charts

import image as I
provide from I:
    * hiding(translate),
  type *,
  data *
end

import lists as L
provide from L: * hiding(filter, range, sort), type *, data * end

import color as C
import constants as Consts
provide from Consts: PI, E end
import reactors as R

import either as Eth
import error as Err
import sets as Sets
import tables as T
import string-dict as SD
import statistics as Stats
import math as Math
import csv as csv

import gdrive-sheets as G
provide from G:
    * hiding(load-spreadsheet),
  type *,
  data *
end

# folded in from ai-library.arr: needed by the AI-specific code below
include string-dict
include valueskeleton
include option
include matrices

var debugging = false


data Posn:
  | posn(x :: Number, y :: Number)
end

# override Pyret's native color constructor with make-color
shadow make-color = C.color

# override Pyret's native range (list) with range (stats)
shadow range = lam(t :: Table, col :: String) block:
  l = t.column(col).sort()
  num-to-string-digits(Math.max(l) - Math.min(l), 2)
end

fun nth-root(n, r): expt(n, 1 / r) end

var display-chart = lam(c) block: 
  when debugging: print(c.get-spec()) end
  c.display() 
end

fun string-trim(s :: String) -> String:
  doc: "Strips leading and trailing whitespace from a string"
  is-space = lam(c): string-contains(" \t\n\r", c) end
  fun drop-leading(chars):
    if is-empty(chars) or not(is-space(chars.first)):
      chars
    else:
      drop-leading(chars.rest)
    end
  end
  chars = string-explode(s)
  L.reverse(drop-leading(L.reverse(drop-leading(chars)))).join-str("")
end

#################################################
# Numerical functions

fun round-digits(val, digits):
  shadow scale = expt(10, digits)
  num-round(val * scale) / scale
end

fun num-round-to(n :: Number, digits :: Number) -> Roughnum:
  num-to-roughnum(round-digits(n, digits))
end

fun log-base(base, val):
  lg = num-log(val) / num-log(base)
  lg-round = round-digits(lg, 4)
  if roughly-equal(lg-round, lg) and roughly-equal(expt(base, lg-round), val):
    lg-round
  else:
    lg
  end
end

fun log(n): log-base(10, n) end
ln = num-log
data ShrinkResult:
  | fits(s :: String)
  | overflow
  | cantfit
end


TRIG_ROUND_DIGITS = 10

fun rough-round-digits(val, digits):
  num-to-roughnum(num-round(val * expt(10, digits)) / expt(10, digits))
end


shadow sin = lam(n):
  rough-round-digits(num-sin(n), TRIG_ROUND_DIGITS)
end

shadow cos = lam(n):
  rough-round-digits(num-cos(n), TRIG_ROUND_DIGITS)
end

shadow tan = lam(n):
  rough-round-digits(num-tan(n), TRIG_ROUND_DIGITS)
end

# degree-consuming variants of sin, cos, and tan
fun sin-deg(n): sin(n * (PI / 180)) end
fun cos-deg(n): cos(n * (PI / 180)) end
fun tan-deg(n): tan(n * (PI / 180)) end

# --- string-form number utilities ---

fun string-to-number-i(s):
  cases(Option) string-to-number(s):
    | some(n) => n
    | none => -1e100
  end
end

fun strip-roughnum-prefix(s :: String) -> String:
  string-substring(s, 1, string-length(s))
end

fun normalize-exponent(s :: String) -> String:
  e-pos = string-index-of(s, 'e')
  if e-pos == -1: s
  else if string-char-at(s, e-pos + 1) == '+':
    string-substring(s, 0, e-pos) + 'e' +
    string-substring(s, e-pos + 2, string-length(s))
  else: s
  end
end

fun num-to-fixnum-str(n):
  normalize-exponent(strip-roughnum-prefix(num-to-string(num-to-roughnum(n))))
end

fun num-to-fixnum-no-exp-str(n):
  make-unsci(num-to-fixnum-str(n))
end

fun count-leading-zeros(s):
  fun helper(i):
    if i == string-length(s): i
    else if string-char-at(s, i) == '0': helper(i + 1)
    else: i
    end
  end
  helper(0)
end

fun str-girth(num-str):
  doc: ```
       Compute floor(log10(|n|)) directly from a no-exponent string
       form of n.  Returns 0 for "0".
       ```
  dot-pos = string-index-of(num-str, '.')
  int-str =
    if dot-pos < 0: num-str
    else: string-substring(num-str, 0, dot-pos)
    end
  if (int-str == '') or (int-str == '0'):
    dec-str =
      if dot-pos < 0: ''
      else: string-substring(num-str, dot-pos + 1, string-length(num-str))
      end
    leading-zeros = count-leading-zeros(dec-str)
    if leading-zeros == string-length(dec-str): 0
    else: 0 - (leading-zeros + 1)
    end
  else:
    string-length(int-str) - 1
  end
end

# --- shrinking ---

fun shrink-dec-part(dec-part, max-chars):
  doc: ```
       Truncate a fractional-digit string to fit `max-chars`, rounding
       the next digit if it's >= 5.  Returns:
         fits(s)   - the (possibly zero-padded) shrunk string
         overflow  - rounding carried past the leftmost digit
         cantfit   - max-chars too small to represent anything
       ```
  dec-part-len = string-length(dec-part)
  if max-chars < -1: cantfit
  else if max-chars == -1:
    if (dec-part-len > 0) and
      (string-to-number-i(string-char-at(dec-part, 0)) >= 5):
      overflow
    else:
      fits('')
    end
  else if dec-part-len == 0:
    fits('')
  else:
    head-str = string-substring(dec-part, 0, max-chars)
    next-digit = string-to-number-i(
      string-char-at(dec-part, max-chars))
    head-num = if head-str == '': 0 else: string-to-number-i(head-str) end
    rounded-num = if next-digit >= 5: head-num + 1 else: head-num end
    rounded-str = num-to-string(rounded-num)
    padding-len = max-chars - string-length(rounded-str)
    if padding-len < 0:
      overflow
    else:
      fits(string-repeat('0', padding-len) + rounded-str)
    end
  end
end

fun split-num-str(num-str):
  doc: "Decompose a numeric string into {int-part; frac-part; expt-part}."
  len = string-length(num-str)
  dot-pos = string-index-of(num-str, '.')
  if dot-pos < 0:
    e-pos = string-index-of(num-str, 'e')
    if e-pos < 0:
      {num-str; ''; ''}
    else:
      {string-substring(num-str, 0, e-pos);
        '';
        string-substring(num-str, e-pos, len)}
    end
  else:
    int-part = string-substring(num-str, 0, dot-pos)
    frac-expt-part = string-substring(num-str, dot-pos + 1, len)
    fe-len = string-length(frac-expt-part)
    e-pos = string-index-of(frac-expt-part, 'e')
    if e-pos < 0:
      {int-part; frac-expt-part; ''}
    else:
      {int-part;
        string-substring(frac-expt-part, 0, e-pos);
        string-substring(frac-expt-part, e-pos, fe-len)}
    end
  end
end

fun shrink-dec(num-str, max-chars):
  len = string-length(num-str)
  if len <= max-chars:
    fits(num-str)
  else:
    {int-part; frac-part; expt-part} = split-num-str(num-str)
    int-part-len = string-length(int-part)
    expt-part-len = string-length(expt-part)
    if int-part-len > max-chars:
      cantfit
    else:
      cases(ShrinkResult) shrink-dec-part(frac-part,
            max-chars - (int-part-len + expt-part-len + 1)):
        | cantfit => cantfit
        | overflow =>
          int-part-num = string-to-number-i(int-part)
          carried = num-to-string(int-part-num + 1) + expt-part
          if string-length(carried) <= max-chars: fits(carried)
          else: cantfit
          end
        | fits(s) =>
          if s == '': fits(int-part + expt-part)
          else: fits(int-part + '.' + s + expt-part)
          end
      end
    end
  end
end

# --- scientific notation construction ---

fun mantissa-parts(int-str, dec-str, girth):
  if girth >= 0:
    {string-char-at(int-str, 0);
      string-substring(int-str, 1, string-length(int-str)) + dec-str}
  else:
    neg-girth = 0 - girth
    dec-str-len = string-length(dec-str)
    {string-char-at(dec-str, neg-girth - 1);
      if neg-girth == dec-str-len: '0'
      else: string-substring(dec-str, neg-girth, dec-str-len)
      end}
  end
end

fun to-scientific(num-str, girth):
  len = string-length(num-str)
  dot-pos = string-index-of(num-str, '.')
  int-str =
    if dot-pos > -1: string-substring(num-str, 0, dot-pos)
    else: num-str
    end
  dec-str =
    if dot-pos > -1: string-substring(num-str, dot-pos + 1, len)
    else: ''
    end
  {m-int; m-frac} = mantissa-parts(int-str, dec-str, girth)
  expt-str =
    if girth == 0: ''
    else if girth > 0: 'e' + num-to-string(girth)
    else: 'e-' + num-to-string(0 - girth)
    end
  m-int + '.' + m-frac + expt-str
end

fun make-sci(underlying-num-str, max-chars) -> ShrinkResult:
  girth = str-girth(underlying-num-str)
  output =
    if (girth > 0) and (girth < max-chars):
      if string-index-of(underlying-num-str, '.') < 0:
        underlying-num-str + '.'
      else:
        underlying-num-str
      end
    else:
      to-scientific(underlying-num-str, girth)
    end
  if string-length(output) <= max-chars: fits(output)
  else: shrink-dec(output, max-chars)
  end
end

fun make-unsci(underlying-num-str):
  e-pos = string-index-of(underlying-num-str, 'e')
  if e-pos < 0: underlying-num-str
  else:
    underlying-num-str-len = string-length(underlying-num-str)
    mantissa-str = string-substring(underlying-num-str, 0, e-pos)
    exponent = string-to-number-i(string-substring(
        underlying-num-str, e-pos + 1, underlying-num-str-len))
    mantissa-len = string-length(mantissa-str)
    mantissa-dot-pos = string-index-of(mantissa-str, '.')
    mantissa-int-str =
      if mantissa-dot-pos > -1:
        string-substring(mantissa-str, 0, mantissa-dot-pos)
      else: mantissa-str
      end
    mantissa-frac-str =
      if mantissa-dot-pos > -1:
        string-substring(mantissa-str, mantissa-dot-pos + 1, mantissa-len)
      else: ''
      end
    if exponent == 0:
      underlying-num-str
    else if exponent > 0:
      mantissa-frac-len = string-length(mantissa-frac-str)
      if mantissa-frac-len == exponent:
        mantissa-int-str + mantissa-frac-str
      else if mantissa-frac-len < exponent:
        mantissa-int-str + mantissa-frac-str +
        string-repeat('0', exponent - mantissa-frac-len)
      else:
        mantissa-int-str +
        string-substring(mantissa-frac-str, 0, exponent) + '.' +
        string-substring(mantissa-frac-str, exponent, mantissa-frac-len)
      end
    else:
      shadow exponent = 0 - exponent
      mantissa-int-len = string-length(mantissa-int-str)
      if mantissa-int-len == exponent:
        '0.' + mantissa-int-str + mantissa-frac-str
      else if mantissa-int-len < exponent:
        '0.' + string-repeat('0', (exponent - mantissa-int-len) - 1) +
        mantissa-int-str + mantissa-frac-str
      else:
        string-substring(mantissa-int-str, 0, mantissa-int-len - exponent) +
        '.' +
        string-substring(mantissa-int-str, mantissa-int-len - exponent,
          mantissa-int-len)
      end
    end
  end
end

# --- top-level ---

fun compute-prefix(n):
  (if num-is-roughnum(n): '~' else: '' end) +
  (if n < 0: '-' else: '' end)
end

fun natural-min-len(full-no-exp :: String) -> Number:
  doc: ```
       Chars natural decimal needs just to convey magnitude + 1 sig digit.
       ```
  dot-pos = string-index-of(full-no-exp, '.')
  if dot-pos < 0:
    string-length(full-no-exp)
  else:
    int-str = string-substring(full-no-exp, 0, dot-pos)
    if int-str == '0':
      dec-str = string-substring(full-no-exp, dot-pos + 1,
        string-length(full-no-exp))
      2 + count-leading-zeros(dec-str) + 1
    else:
      dot-pos
    end
  end
end

fun easy-num-repr(n :: Number, max-chars :: Number) -> String:
  doc: ```
       Render `n` as a string of at most `max-chars` characters using
       the most accuracy-preserving non-rational decimal representation
       that fits.  Prefers natural decimal; falls back to scientific
       when natural would lose magnitude or fail to fit.  Raises if
       even scientific cannot fit.
       ```
  prefix = compute-prefix(n)
  budget = max-chars - string-length(prefix)

  result =
    if num-is-rational(n) and (n == 0):
      fits('0')
    else if num-is-rational(n) and (abs(n) == 1):
      fits('1')
    else:
      full-no-exp = num-to-fixnum-no-exp-str(abs(n))
      if natural-min-len(full-no-exp) <= budget:
        shrink-dec(full-no-exp, budget)
      else:
        full-with-exp = num-to-fixnum-str(abs(n))
        if string-contains(full-with-exp, 'e'):
          if string-length(full-with-exp) <= budget:
            fits(full-with-exp)
          else:
            shrink-dec(full-with-exp, budget)
          end
        else:
          make-sci(full-with-exp, budget)
        end
      end
    end

  cases(ShrinkResult) result:
    | fits(s) => prefix + s
    | cantfit =>
      raise('Could not fit ' + prefix +
        num-to-fixnum-no-exp-str(abs(n)) +
        ' into ' + tostring(max-chars) + ' chars')
  end
end



#################################################################################
# image-url
# shadow the native one with a wrapper than can identify and rewrite google share URLs
shadow image-url = lam(str) block:
  google-check = string-split-all(str, "https://drive.google.com/file/d/")
  if (google-check.length() > 1) block:
    download-prefix = "https://drive.google.com/uc?export=download&id="
    split-slashes = string-split-all(google-check.get(1), "/")
    I.image-url(download-prefix + split-slashes.get(0))
  else:
    I.image-url(str)
  end
end



#################################################################################
# Table Functions
# check that the table isn't empty, has all the necessary columns, and contains no blanks

# check to ensure that every value is actually a number
is-all-numbers = _.all(is-number)
fun ensure-numbers(l :: List<Number>%(is-all-numbers)): l end

fun check-integrity(t :: Table, cols :: List<String>) block:
  t-cols = t.column-names()
  check-col = lam(c): if t-cols.member(c): nothing
    else: raise(Err.message-exception("'" + c + "' is not a column in this table. Columns are: " + t-cols.join-str(", ")))
    end
  end
  cols.each(check-col)
  if (t.all-rows().length() == 0):
    raise(Err.message-exception("This table contains no data rows (it's empty!)"))
  else:
    L.each(lam(c):
        if is-Option(t.row-n(0)[c]):
          raise(Err.message-exception("This table contains blank cells in column " + c))
        else:
          nothing
        end
      end,
      t.column-names())
  end
end


# shadow the built-in function, with one naive twist:
# if it looks like a sheets URL, try parsing out the fileID
# for the user. Otherwise, just fall back to the native
# library function
fun load-spreadsheet(url :: String) block:
  if (string-length(url) < 39):
    G.load-spreadsheet(url)
  else if (string-substring(url, 0, 39) <> "https://docs.google.com/spreadsheets/d/"):
    G.load-spreadsheet(url)
  else:
    rest = string-substring(url, 39, string-length(url))
    G.load-spreadsheet(string-split(rest,"/").get(0))
  end
end

# Strings, Integers and numbers with 2 decimals are displayed exactly
# more than 2 decimals are displayed as roughnums
fun get-labels(t, ls) block:
  ls-col = t.column(ls)
  if is-number(ls-col.get(0)):
    ls-col.map(lam(x) block:
        rounded = num-round(x * 100) / 100
        if num-is-integer(x): num-to-string-digits(x, 0)
        else if (x == rounded): num-to-string-digits(x, 2)
        else: "~" + num-to-string-digits(x, 2)
        end
      end)
  else:
    ls-col.map(to-string)
  end
end

# Optimally-distinct list of colors taken from
# https://stackoverflow.com/a/12224359/12026982
COLORS = [list:
  make-color(51,102,204, 1),
  make-color(220,57,18, 1),
  make-color(255,153,0, 1),
  make-color(16,150,24, 1),
  make-color(153,0,153, 1),
  make-color(0,153,198, 1),
  make-color(221,68,119, 1),
  make-color(102,170,0, 1),
  make-color(184,46,46, 1),
  make-color(49,99,149, 1),
  make-color(153,68,153, 1),
  make-color(34,170,153, 1),
  make-color(170,170,17, 1),
  make-color(102,51,204, 1),
  make-color(230,115,0, 1),
  make-color(139,7,7, 1),
  make-color(101,16,103, 1),
  make-color(50,146,98, 1),
  make-color(85,116,166, 1),
  make-color(59,62,172, 1),
  make-color(183,115,34, 1),
  make-color(22,214,32, 1),
  make-color(185,19,131, 1),
  make-color(244,53,158, 1),
  make-color(156,89,53, 1),
  make-color(169,196,19, 1),
  make-color(42,119,141, 1),
  make-color(102,141,28, 1),
  make-color(190,164,19, 1),
  make-color(12,89,34, 1),
  make-color(116,52,17, 1)]

# maintain a mutable dict mapping string values to colors, so that any
# categorical display will have the same colors for the same value across
# program-opens (closing and re-opening the program will clear the dict).
var string-colors = [SD.mutable-string-dict:]
var colorIdx = 0

fun nextColor() block:
  if (colorIdx < (COLORS.length() - 1)):
    colorIdx := colorIdx + 1
  else: colorIdx := 0
  end
  COLORS.get(colorIdx)
end

# Given a table and a column name, extract distinct string values from
# that col and get the associated colors in the string-colors dict. If
# no color is assigned, grab a new one from the colors list and assign it
# Given a table and a column name, extract distinct string values from
# that col and get the associated colors in the string-colors dict. If
# no color is assigned, grab a new one from the colors list and assign it
distinct-colors :: (t :: Table, col :: String) -> Table
fun distinct-colors(t, col):
  t.build-column("_color", lam(r) block:
      key = to-repr(r.get-value(col))
      when not(string-colors.has-key-now(key)):
        string-colors.set-now(key, nextColor())
      end
      string-colors.get-value-now(key)
    end)
end


fun add-margin(img) block:
  margin = 75
  overlay(
    center-pinhole(img),
    rectangle(
      image-width(img) + margin,
      image-height(img) + margin,
      "outline",
      "transparent"))
end

fun make-title(str-list):
  fold_n(
    lam(i, acc, str):
      beside(
        acc,
        if num-is-integer(i / 2): text(" " + str + " ", 18, "black")
        else: text-font(str, 16, "blue", "Courier",
            "swiss", "normal", "normal", false)
        end)
    end,
    0,
    text("",18,"black"),
    str-list)
end

fun minimum(t :: Table, col :: String) block:
  check-integrity(t, [list: col])
  if not(is-number(t.column(col).get(0))):
    raise(Err.message-exception("Cannot compute the minimum, because the '" + col + "' column does not contain quantitative data"))
  else:
    Math.min(t.column(col))
  end
end

fun maximum(t :: Table, col :: String) block:
  check-integrity(t, [list: col])
  if not(is-number(t.column(col).get(0))):
    raise(Err.message-exception("Cannot compute the maximum, because the '" + col + "' column does not contain quantitative data"))
  else:
    Math.max(t.column(col))
  end
end

fun iqr(t :: Table, col :: String) block:
  check-integrity(t, [list: col])
  l = t.column(col).sort()
  first-half = l.split-at(num-floor(l.length() / 2)).prefix
  second-half = l.split-at(num-ceiling(l.length() / 2)).suffix
  num-to-string-digits(Stats.median(second-half) - Stats.median(first-half),2)
end
fun IQR(t, col): iqr(t, col) end

fun get-5-num-summary(t :: Table, col :: String) block:
  check-integrity(t, [list: col])
  l = t.column(col)
  shadow l = l.sort()
  first-half = l.split-at(num-floor(l.length() / 2)).prefix
  second-half = l.split-at(num-ceiling(l.length() / 2)).suffix
  shadow minimum = num-to-string-digits(Math.min(l), 2)
  Q1 = num-to-string-digits(Stats.median(first-half), 2)
  Q2 = num-to-string-digits(Stats.median(l), 1)
  Q3 = num-to-string-digits(Stats.median(second-half), 2)
  shadow maximum = num-to-string-digits(Math.max(l), 2)
  R = num-to-string-digits(Math.max(l) - Math.min(l), 2)
  [list: "Min:", minimum, ",  Q1:", Q1, ",  Median:", Q2, ",  Q3:", Q3, ",  Max:", maximum].join-str("")
end


fun row-n(t :: Table, n :: Number) block:
  check-integrity(t, [list: ])
  t.row-n(n)
end

# if the column is a boolean, sort by its repr; if it's a string, sort
# case-insensitively; otherwise sort directly
shadow sort = lam(t :: Table, col :: String, asc :: Boolean):
  if (t.all-rows().length() == 0):
    t.order-by(col, asc)
  else if is-boolean(t.row-n(0)[col]):
    t.build-column("tmp", lam(r): to-repr(r[col]) end).order-by("tmp", asc).drop("tmp")
  else if is-string(t.row-n(0)[col]):
    t.build-column("tmp", lam(r): string-to-lower(r[col]) end).order-by("tmp", asc).drop("tmp")
  else:
    t.order-by(col, asc)
  end
end

shadow filter = lam(t :: Table, fn :: (Row->Boolean)):
  t.filter(fn)
end

fun build-column(t :: Table, col :: String, fn :: (Row->Any)):
  t.build-column(col, fn)
end

fun transform-column(t :: Table, col :: String, fn :: (Row->Any)):
  t.transform-column(col, fn)
end

fun find-by-id(t :: Table, id):
  id-col = t.column-names().get(0)
  row-n(filter(t, lam(r): r[id-col] == id end), 0)
end

fun stack-table(t1 :: Table, t2 :: Table): t1.stack(t2) end

fun stack-tables(ts :: List<Table>): 
  L.fold({(base, t): base.stack(t)}, ts.first, ts.rest)
end

## CENTER AND SPREAD #############################################
mean :: (t :: Table, col :: String) -> Number
fun mean(t, col) block:
  check-integrity(t, [list: col])
  if not(is-number(t.column(col).get(0))):
    raise(Err.message-exception("Cannot compute the mean, because the specified column does not contain numeric data"))
  else:
    Stats.mean(ensure-numbers(t.column(col)))
  end
end

median :: (t :: Table, col :: String) -> Number
fun median(t, col) block:
  check-integrity(t, [list: col])
  if not(is-number(t.column(col).get(0))):
    raise(Err.message-exception("Cannot compute the median, because the specified column does not contain numeric data"))
  else:
    Stats.median(ensure-numbers(t.column(col)))
  end
end

modes  :: (t :: Table, col :: String) -> List<Number>
fun modes( t, col) block:
  check-integrity(t, [list: col])
  Stats.modes(t.column(col))
end

shadow sum = lam(t :: Table, col :: String) block:
  check-integrity(t, [list: col])
  if not(is-number(t.column(col).get(0))):
    raise(Err.message-exception("Cannot compute the sum, because the specified column does not contain numeric data"))
  else:
    Math.sum(ensure-numbers(t.column(col)))
  end
end

stdev  :: (t :: Table, col :: String) -> Number
fun stdev( t, col) block:
  check-integrity(t, [list: col])
  if not(is-number(t.column(col).get(0))):
    raise(Err.message-exception("Cannot compute the mean, because the specified column does not contain numeric data"))
  else:
    Stats.stdev-sample(ensure-numbers(t.column(col)))
  end
end

r-value:: (t :: Table, xs :: String, ys :: String) -> Number
fun r-value(t, xs, ys) block:
  check-integrity(t, [list: xs, ys])
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot compute the mean, because the specified columns do not contain numeric data"))
  else:
    fn = Stats.linear-regression(
      ensure-numbers(t.column(xs)),
      ensure-numbers(t.column(ys)))
    dir = if ((fn(1) - fn(0)) < 0): -1 else: 1 end
    dir * num-sqrt(Stats.r-squared(t.column(xs), t.column(ys), fn))
  end
end

## PIE AND BAR CHARTS ###########################################

# given a summary table with columns <col> and "frequency",
# apply a function <f> to each row and produce the
# resulting image-list, or a helpful error
fun make-images-from-grouped-rows(summary, col, f):
  cases(Eth.Either) run-task(lam():
          summary.all-rows().map(f)
        end):
    | left(v) => v
    | right(v) => raise(Err.message-exception("Could not find an image for one of the values in the '" + col + "' column. Check to make sure that your drawing function correctly produces an image for each unique entry"))
  end
end

fun pie-chart-raw(t, ls, vs, column-name) block:
  labels = get-labels(t, ls)
  series = from-list.pie-chart(labels, ensure-numbers(t.column(vs)))
    .colors(t.column("_color"))
  chart = render-chart(series).width(600).height(400)
  img = display-chart(chart)
  title = make-title([list:"Distribution of", column-name])
  above(title, add-margin(img))
end

# no need to check integrity - all parent functions do it first
fun bar-chart-raw(t, ls, vs, column-name) block:
  labels = get-labels(t, ls)
  series = from-list.bar-chart(labels, ensure-numbers(t.column(vs)))
    .colors(t.column("_color"))
  chart = render-chart(series).width(600).height(400)
    .x-axis(column-name)
    .y-axis(vs)
    .y-min(0)
  img = display-chart(chart)
  title = make-title([list:"Distribution of", column-name])
  above(title, img)
end

# wrappers for raw charts: extract a summary table
# and compute the colors, and display
pie-chart :: (t :: Table, col :: String) -> Image
fun pie-chart(t, col) block:
  check-integrity(t, [list: col])
  title = "Cases for column: '" + col + "'"
  summary = count(t, col)
  color-table = distinct-colors(summary, col)
  pie-chart-raw(color-table, col, "frequency", col)
end


color-pie-chart :: (t :: Table, col :: String, f :: (Row -> String)) -> Image
fun color-pie-chart(t, col, f) block:
  check-integrity(t, [list: col])
  summary = count(t, col)
  color-strs = make-images-from-grouped-rows(summary, col, f)
  colors = color-strs.map(color-named)
  series = from-list.pie-chart(
    get-labels(summary, col),
    ensure-numbers(summary.column("frequency")))
    .colors(colors)
  chart = render-chart(series).width(600).height(400)
  img = display-chart(chart)
  title = make-title([list:"Distribution of", col])
  above(title, add-margin(img))
end

#|
   image-pie-chart :: (t :: Table, col :: String, f :: (Row -> Image)) -> Image
   fun image-pie-chart(t, col, f) block:
  check-integrity(t, [list: col])
  summary = count(t, col)
  images = make-images-from-grouped-rows(summary, col, f)
  series = from-list.image-pie-chart(
    images,
    get-labels(summary, col),
    ensure-numbers(summary.column("frequency")))
  chart = render-chart(series)
  img = display-chart(chart)
  title = make-title([list:"Distribution of", col])
  above(title, add-margin(img))
   end
|#
bar-chart :: (t :: Table, col :: String) -> Image
fun bar-chart(t, col) block:
  check-integrity(t, [list: col])
  summary = count(t, col)
  color-table = distinct-colors(summary, col)
  bar-chart-raw(color-table, col, "frequency", col)
end


color-bar-chart :: (t :: Table, col :: String, f :: (Row -> String)) -> Image
fun color-bar-chart(t, col, f) block:
  fun image-from-row(r): square(10, "solid", f(r)) end
  image-bar-chart(t, col, image-from-row)
end


image-bar-chart :: (t :: Table, col :: String, f :: (Row -> Image)) -> Image
fun image-bar-chart(t, col, f) block:
  check-integrity(t, [list: col])
  summary = count(t, col)
  images = make-images-from-grouped-rows(summary, col, f)
  series = from-list.image-bar-chart(
    images,
    get-labels(summary, col),
    ensure-numbers(summary.column("frequency")))
  chart = render-chart(series).width(600).height(400).y-min(0)
  img = display-chart(chart)
  title = make-title([list:"Distribution of", col])
  above(title, add-margin(img))
end

# wrappers for summarized charts: check for numeric
# data, extract the colors, and display
fun pie-chart-summarized(t, ls, vs) block:
  check-integrity(t, [list: ls, vs])
  if not(is-number(t.column(vs).get(0))):
    raise(Err.message-exception("Cannot make a summarized pie chart, because the 'values' column does not contain numeric data"))
  else:
    color-table = distinct-colors(t, ls)
    pie-chart-raw(color-table, ls, vs, ls)
  end
end

fun bar-chart-summarized(t, ls, vs) block:
  check-integrity(t, [list: ls, vs])
  if not(is-number(t.column(vs).get(0))):
    raise(Err.message-exception("Cannot make a summarized bar chart, because the 'values' column does not contain numeric data"))
  else:
    color-table = distinct-colors(t, vs)
    bar-chart-raw(color-table, ls, vs, ls)
  end
end


stacked-bar-chart :: (t :: Table, col :: String, subcol :: String) -> Image
fun stacked-bar-chart(t, col, subcol) block:
  check-integrity(t, [list: col, subcol])
  shadow segments = Sets.list-to-set(t.get-column(subcol).map(to-repr)).to-list().sort()
  color-list = segments.map(lam(_): nextColor() end)
  tab = group-and-subgroup(t, col, subcol)
  series = from-list.stacked-bar-chart(
    tab.get-column("group").map(to-repr),
    tab.get-column("data"),
    segments)
    .stacking-type(percent)
    .colors(color-list)
  chart = render-chart(series).width(600).height(400)
    .x-axis(col).y-axis(subcol)
  img = display-chart(chart)
  title = make-title([list:"Distribution of", subcol, "by", col])
  above(title, add-margin(img))
end

fun stacked-bar-chart-summarized(t, categories, column-list) block:
  check-integrity(t, [list: categories].append(column-list))
  color-list = column-list.map(lam(_): nextColor() end)
  groups = t.get-column(categories).map(to-repr)
  raw_data = map(lam(col): t.get-column(col) end, column-list)
  zipped_data = map_n(lam(n, _):
      map_n(lam(m,_): raw_data.get(m).get(n) end, 0, raw_data)
    end, 0, raw_data.get(0))
  series = from-list.stacked-bar-chart(
    groups,
    zipped_data,
    column-list)
    .colors(color-list)
  chart = render-chart(series).width(600).height(400)
  display-chart(chart)
end


multi-bar-chart :: (t :: Table, col :: String, subcol :: String) -> Image
fun multi-bar-chart(t, col, subcol) block:
  check-integrity(t, [list: col, subcol])
  shadow segments = Sets.list-to-set(t.get-column(subcol).map(to-repr))
    .to-list().sort()
  color-list = segments.map(lam(_): nextColor() end)
  tab = group-and-subgroup(t, col, subcol)
  series = from-list.grouped-bar-chart(
    tab.get-column("group").map(to-repr),
    tab.get-column("data"),
    segments)
    .colors(color-list)
  chart = render-chart(series).width(600).height(400)
    .x-axis(col + " ⋲ " + subcol)
    .y-axis("frequency")
  img = display-chart(chart)
  title = make-title([list:"Distribution of", subcol, "by", col])
  above(title, add-margin(img))
end

fun multi-bar-chart-summarized(t, categories, column-list) block:
  check-integrity(t, [list: categories].append(column-list))
  color-list = column-list.map(lam(_): nextColor() end)
  groups = t.get-column(categories).map(to-repr)
  raw_data = map(lam(col): t.get-column(col) end, column-list)
  zipped_data = map_n(lam(n, _):
      map_n(lam(m,_): raw_data.get(m).get(n) end, 0, raw_data)
    end, 0, raw_data.get(0))
  series = from-list.grouped-bar-chart(
    groups,
    zipped_data,
    column-list)
    .colors(color-list)
  chart = render-chart(series).width(600).height(400)
  display-chart(chart)
end



## DOT PLOTS #############################################

simple-dot-plot :: (t :: Table, vals :: String) -> Image
fun simple-dot-plot(t, vals) block:
  check-integrity(t, [list: vals])
  is-quant = is-number(t.column(vals).get(0))
  vs = if is-quant: t.column(vals) else: t.column(vals).map(to-string) end
  series = if is-quant:
    from-list.num-dot-chart(vs)
  else:
    from-list.dot-chart(vs)
  end
  chart = render-chart(series).width(600).height(400)
    .x-axis(vals).y-axis("frequency")
  img = display-chart(chart)
  title = make-title([list:"Dot Plot of", vals])
  above(title, add-margin(img))
end

dot-plot :: (t :: Table, labels :: String, vals :: String) -> Image
fun dot-plot(t, labels, vals) block:
  check-integrity(t, [list: labels, vals])
  ls = t.column(labels).map(to-repr)
  is-quant = is-number(t.column(vals).get(0))
  vs = if is-quant: t.column(vals) else: t.column(vals).map(to-string) end
  series = if is-quant:
    from-list.num-dot-chart(vs).labels(ls)
  else:
    from-list.dot-chart(vs).labels(ls)
  end
  chart = render-chart(series).width(600).height(400)
    .x-axis(vals)
    .y-axis("frequency")
  img = display-chart(chart)
  title = make-title([list:"Dot Plot of", vals])
  above(title, add-margin(img))
end


fun color-dot-plot(t, vals, f :: (Row -> Image)) block:
  fun image-from-row(r): square(10, "solid", f(r)) end
  image-dot-plot(t, vals, image-from-row)
end

fun image-dot-plot(t, vals, f :: (Row -> Image)) block:
  check-integrity(t, [list: vals])
  is-quant = is-number(t.column(vals).get(0))
  vs = if is-quant: t.column(vals) else: t.column(vals).map(to-string) end
  images = t.all-rows().map(f)
  max-height = images.map(image-height).foldl(num-max, 0)
  series = if is-quant:
    from-list.num-dot-chart(vs)
  else:
    from-list.dot-chart(vs)
  end
  chart = render-chart(series.image-labels(images)).width(600).height(400)
    .x-axis(vals).y-axis("frequency")
  img = display-chart(chart)
  title = make-title([list:"Dot Plot of", vals])
  above(title, add-margin(img))
end



## HISTOGRAMS #############################################
simple-histogram :: (t :: Table, vals :: String, bin-width :: Number) -> Image
fun simple-histogram(t, vals, bin-width) block:
  doc: "wrap histogram so that the bin-width is set"
  check-integrity(t, [list: vals])
  if not(is-number(t.column(vals).get(0))):
    raise(Err.message-exception("Cannot make a histogram, because the '" + vals + "' column does not contain quantitative data"))
  else:
    series = from-list.histogram(ensure-numbers(t.column(vals))).bin-width(bin-width)
    chart = render-chart(series).width(600).height(400)
      .x-axis(vals)
      .y-axis("frequency")
    img = display-chart(chart)
    title = make-title([list:"Distribution of", vals])
    above(title, add-margin(img))
  end
end

histogram :: (t :: Table, labels :: String, vals :: String, bin-width :: Number) -> Image
fun histogram(t, labels, vals, bin-width) block:
  doc: "wrap histogram so that the bin-width is set"
  check-integrity(t, [list: labels, vals])
  if not(is-number(t.column(vals).get(0))):
    raise(Err.message-exception("Cannot make a histogram, because the '" + vals + "' column does not contain quantitative data"))
  else:
    series = from-list.histogram(ensure-numbers(t.column(vals)))
      .labels(t.column(labels).map(to-repr))
      .bin-width(bin-width)
    chart = render-chart(series).width(600).height(400)
      .x-axis(vals)
      .y-axis("frequency")
    img = display-chart(chart)
    title = make-title([list:"Distribution of", vals])
    above(title, add-margin(img))
  end
end

color-histogram :: (t :: Table, vals :: String, bin-width :: Number, f :: (Row -> String)) -> Image
fun color-histogram(t, vals, bin-width, f) block:
  fun image-from-row(r): square(10, "solid", f(r)) end
  image-histogram(t, vals, bin-width, image-from-row)
end

image-histogram :: (t :: Table, vals :: String, bin-width :: Number, f :: (Row -> Image)) -> Image
fun image-histogram(t, vals, bin-width, f) block:
  check-integrity(t, [list: vals])
  images = t.all-rows().map(f)
  if not(is-number(t.column(vals).get(0))):
    raise(Err.message-exception("Cannot make a histogram, because the '" + vals + "' column does not contain quantitative data"))
  else:
    series = from-list.image-histogram(images, ensure-numbers(t.column(vals)))
      .bin-width(bin-width)
    chart = render-chart(series).width(600).height(400)
      .x-axis(vals)
      .y-axis("frequency")
    img = display-chart(chart)
    title = make-title([list:"Distribution of", vals])
    above(title, add-margin(img))
  end
end

scaled-histogram :: (t :: Table, vals :: String, bin-width :: Number, low :: Number, high :: Number) -> Image
fun scaled-histogram(t, vals, bin-width, low, high) block:
  doc: "wrap histogram so that the bin-width is set"
  check-integrity(t, [list: vals])
  if not(is-number(t.column(vals).get(0))):
    raise(Err.message-exception("Cannot make a histogram, because the '" + vals + "' column does not contain quantitative data"))
  else:
    series = from-list.histogram(ensure-numbers(t.column(vals))).bin-width(bin-width)
    chart = render-chart(series).width(600).height(400)
      .x-axis(vals)
      .y-axis("frequency")
      .min(low).max(high)
    img = display-chart(chart)
    title = make-title([list:"Distribution of", vals])
    above(title, add-margin(img))
  end
end



## BOX PLOTS #############################################

box-plot-raw :: (t :: Table, vs :: String, low :: Number, high :: Number, horizontal :: Boolean, showOutliers :: Boolean) -> Image
fun box-plot-raw(t, vs, low, high, horizontal, showOutliers) block:
  l = ensure-numbers(t.column(vs))
  padding = (high - low) / 1000 # pad with 1000th the range
  if l.length() < 2:
    raise(Err.message-exception("At least two rows are needed to make a box plot"))
  else if not(is-number(l.get(0))):
    raise(Err.message-exception("Cannot make a box plot, because the 'values' column does not contain numeric data"))
  else if (low > high):
    raise(Err.message-exception("Min value must be lower than Max value"))
  else:
    series = from-list.labeled-box-plot([list: vs], [list: l])
      .horizontal(horizontal).show-outliers(showOutliers)
      .color(make-color(0,0,100,1))
    chart = render-chart(series).width(600).height(200)
      .title(get-5-num-summary(t, vs))
      .min(low)
      .max(high + padding)
    img = display-chart(chart)
    title = make-title([list:"Distribution of", vs])
    above(title, add-margin(img))
  end
end

box-plot :: (t :: Table, vs :: String) -> Image
# pass the min as 0 and the max as the largest value in the column
fun box-plot(t, vs) block:
  check-integrity(t, [list: vs])
  lo = Math.min(t.column(vs))
  hi = Math.max(t.column(vs))
  box-plot-raw(t, vs, lo, hi, true, false)
end

box-plot-scaled :: (t :: Table, vs :: String, lo :: Number, hi :: Number) -> Image
fun box-plot-scaled(t, vs, lo, hi) block:
  check-integrity(t, [list: vs])
  box-plot-raw(t, vs, lo, hi, true, false)
end

modified-box-plot :: (t :: Table, vs :: String) -> Image
fun modified-box-plot(t, vs) block:
  check-integrity(t, [list: vs])
  lo = Math.min(t.column(vs))
  hi = Math.max(t.column(vs))
  box-plot-raw(t, vs, lo, hi, true, true)
end

modified-box-plot-scaled :: (t :: Table, vs :: String, lo :: Number, hi :: Number) -> Image
fun modified-box-plot-scaled(t, vs, lo, hi) block:
  check-integrity(t, [list: vs])
  box-plot-raw(t, vs, lo, hi, true, true)
end

vert-box-plot :: (t :: Table, vs :: String) -> Image
fun vert-box-plot(t, vs) block:
  check-integrity(t, [list: vs])
  lo = Math.min(t.column(vs))
  hi = Math.max(t.column(vs))
  box-plot-raw(t, vs, lo, hi, false, false)
end

modified-vert-box-plot :: (t :: Table, vs :: String) -> Image
fun modified-vert-box-plot(t, vs) block:
  check-integrity(t, [list: vs])
  lo = Math.min(t.column(vs))
  hi = Math.max(t.column(vs))
  box-plot-raw(t, vs, lo, hi, false, true)
end

modified-vert-box-plot-scaled :: (t :: Table, vs :: String, lo :: Number, hi :: Number) -> Image
fun modified-vert-box-plot-scaled(t, vs, lo, hi) block:
  check-integrity(t, [list: vs])
  box-plot-raw(t, vs, lo, hi, false, true)
end

## LINE GRAPHS ######################################################
line-graph :: (t :: Table, labels :: String, xs :: String, ys :: String) -> Image
fun line-graph(t, labels, xs, ys) block:
  check-integrity(t, [list: xs, ys])
  l = ensure-numbers(t.column(xs))
  l2 = ensure-numbers(t.column(ys))
  ls = get-labels(t, labels)
  sorted = t.order-by(xs, true) # sort the table by x-axis
  series = from-list.line-plot(sorted.column(xs), sorted.column(ys))
  scatter-series= from-list.scatter-plot(sorted.column(xs), sorted.column(ys)).labels(ls)
  chart = render-charts([list: series, scatter-series]).width(600).height(400)
    .x-axis(xs)
    .y-axis(ys)
  img = display-chart(chart)
  title = make-title([list:"", ys, "vs.", xs])
  above(title, add-margin(img))
end


## LR AND SCATTER PLOTS #############################################
scatter-plot :: (t :: Table, labels :: String, xs :: String, ys :: String) -> Image
fun scatter-plot(t, labels, xs, ys) block:
  check-integrity(t, [list: labels, xs, ys])
  ls = get-labels(t, labels)
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make a scatter plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    series = from-list.scatter-plot(ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys))).labels(ls)
    padding = (Math.max(t.column(ys)) - Math.min(t.column(ys))) / 100
    chart = render-chart(series).width(600).height(400)
      .x-axis(xs)
      .y-axis(ys)
      .y-min(Math.min(t.column(ys)) - padding)
    img = display-chart(chart)
    title = make-title([list:"", ys, "vs.", xs])
    above(title, add-margin(img))
  end
end

simple-scatter-plot :: (t :: Table, xs :: String, ys :: String) -> Image
fun simple-scatter-plot(t, xs, ys) block:
  check-integrity(t, [list: xs, ys])
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make a scatter plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    series = from-list.scatter-plot(ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys)))
    padding = (Math.max(t.column(ys)) - Math.min(t.column(ys))) / 100
    chart = render-chart(series).width(600).height(400)
      .x-axis(xs)
      .y-axis(ys)
      .y-min(Math.min(t.column(ys)) - padding)
    img = display-chart(chart)
    title = make-title([list:"", ys, "vs.", xs])
    above(title, add-margin(img))
  end
end

color-scatter-plot :: (t :: Table, xs :: String, ys :: String, f :: (Row -> Image)) -> Image
fun color-scatter-plot(t, xs, ys, f) block:
  fun image-from-row(r): circle(5, "solid", f(r)) end
  image-scatter-plot(t, xs, ys, image-from-row)
end

image-scatter-plot :: (t :: Table, xs :: String, ys :: String, f :: (Row -> Image)) -> Image
fun image-scatter-plot(t, xs, ys, f) block:
  check-integrity(t, [list: xs, ys])
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make an image scatter plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    x-vals = ensure-numbers(t.column(xs))
    y-vals = ensure-numbers(t.column(ys))
    images = t.all-rows().map(f)
    maxImgH = Math.max(images.map(image-height))
    maxImgW = Math.max(images.map(image-width))
    minX = Math.min(x-vals)
    maxX = Math.max(x-vals)
    minY = Math.min(y-vals)
    maxY = Math.max(y-vals)
    # compute padding using default window size (800pxx600px)
    paddingX = (maxX - minX) * (maxImgW / 800)
    paddingY = (maxY - minY) * (maxImgH / 600)
    series = from-list.scatter-plot(x-vals, y-vals).image-labels(images)
    chart = render-chart(series).width(600).height(400)
      .x-axis(xs)
      .y-axis(ys)
      .x-min(minX - paddingX)
      .x-max(maxX + paddingX)
      .y-min(minY - paddingY)
      .y-max(maxY + paddingY)
    img = display-chart(chart)
    title = make-title([list:"", ys, "vs.", xs])
    above(title, add-margin(img))
  end
end

scatter-plot-3d :: (t :: Table, labels :: String, xs :: String, ys :: String, zs :: String) -> Image
fun scatter-plot-3d(t, labels, xs, ys, zs) block:
  check-integrity(t, [list: labels, xs, ys, zs])
  ls = get-labels(t, labels)
  if not(
      is-number(t.column(xs).get(0)) and 
      is-number(t.column(ys).get(0)) and 
      is-number(t.column(zs).get(0))):
    raise(Err.message-exception("Cannot make a scatter plot, because the 'xs', 'ys', and 'zs' columns must all contain numeric data"))
  else:
    series = from-list.labeled-scatter-plot-3d(ls, ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys)), ensure-numbers(t.column(zs)))
    chart = render-chart(series).width(600).height(400)
      .x-axis(xs)
      .y-axis(ys)
      .z-axis(zs)
    img = display-chart(chart)
    title = make-title([list:"", zs, "vs.", xs, "vs.", ys])
    above(title, add-margin(img))
  end
end


fun make-lr-title(fn, r-sqr-num, s-num) :
  r-num = (if  (fn(1) - fn(0)) < 0: -1 else: 1 end) * num-sqrt(r-sqr-num)
  alpha  = fn(2) - fn(1)
  alpha-str = easy-num-repr(fn(2) - fn(1), 8)
  beta-str =  easy-num-repr(fn(0), 8)
  r-str = easy-num-repr(r-num, 6)
  r-sqr-str = easy-num-repr(r-sqr-num, 6)
  S-str     = easy-num-repr(s-num, 9)
  "y=" + alpha-str + "x + " + beta-str + "  r: " + r-str + "  R²: " + r-sqr-str + " S: " + S-str
end

lr-plot :: (t :: Table, ls :: String, xs :: String, ys :: String) -> Image
fun lr-plot(t, ls, xs, ys) block:
  check-integrity(t, [list: ls, xs, ys])
  labels = get-labels(t, ls)
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make an lr-plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    scatter = from-list.scatter-plot(ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys))).labels(labels)
      .legend("Data")
    padding = (Math.max(t.column(ys)) - Math.min(t.column(ys))) / 100
    fn = Stats.linear-regression(t.column(xs), t.column(ys))
    fn-plot = from-list.function-plot(fn)
      .legend("Model")
    # wrap the xs in a list, and fn in a row-consuming fn
    s-num = regression-model-S(t, [list: xs], ys, {(r): fn(r[xs])})
    r-sqr-num = Stats.r-squared(t.column(xs), t.column(ys), fn)
    chart = render-charts([list: scatter, fn-plot]).width(600).height(400)
      .title(make-lr-title(fn, r-sqr-num, s-num))
      .x-axis(xs)
      .y-axis(ys)
      .y-min(Math.min(t.column(ys)) - padding)
    img = display-chart(chart)
    title = make-title([list:"", ys, "vs.", xs])
    above(title, add-margin(img))
  end
end

simple-lr-plot :: (t :: Table, xs :: String, ys :: String) -> Image
fun simple-lr-plot(t, xs, ys) block:
  check-integrity(t, [list: xs, ys])
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make an lr-plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    scatter = from-list.scatter-plot(
      ensure-numbers(t.column(xs)),
      ensure-numbers(t.column(ys)))
    padding = (Math.max(t.column(ys)) - Math.min(t.column(ys))) / 100
    fn = Stats.linear-regression(t.column(xs), t.column(ys))
    fn-plot = from-list.function-plot(fn)
    # wrap the xs in a list, and fn in a row-consuming fn
    s-num = regression-model-S(t, [list: xs], ys, {(r): fn(r[xs])})
    r-sqr-num = Stats.r-squared(t.column(xs), t.column(ys), fn)
    chart = render-charts([list: scatter, fn-plot]).width(600).height(400)
      .title(make-lr-title(fn, r-sqr-num, s-num))
      .x-axis(xs)
      .y-axis(ys)
      .y-min(Math.min(t.column(ys)) - padding)
    img = display-chart(chart)
    title = make-title([list:"", ys, "vs.", xs])
    above(title, add-margin(img))
  end
end

image-lr-plot :: (t :: Table, xs :: String, ys :: String, f :: (Row -> Image)) -> Image
fun image-lr-plot(t, xs, ys, f) block:
  check-integrity(t, [list: xs, ys])
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make an image-lr-plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    images = t.all-rows().map(f)
    scatter = from-list.scatter-plot(
      ensure-numbers(t.column(xs)),
      ensure-numbers(t.column(ys)))
      .image-labels(images)
      .legend("Data")
    padding = (Math.max(t.column(ys)) - Math.min(t.column(ys))) / 100
    fn = Stats.linear-regression(t.column(xs), t.column(ys))
    fn-plot = from-list.function-plot(fn)
      .legend("Model")
    # wrap the xs in a list, and fn in a row-consuming fn
    s-num = regression-model-S(t, [list: xs], ys, {(r): fn(r[xs])})
    r-sqr-num = Stats.r-squared(t.column(xs), t.column(ys), fn)
    chart = render-charts([list: scatter, fn-plot]).width(600).height(400)
      .title(make-lr-title(fn, r-sqr-num, s-num))
      .x-axis(xs)
      .y-axis(ys)
      .y-min(Math.min(t.column(ys)) - padding)
    img = display-chart(chart)
    title = make-title([list:"", ys, "vs.", xs])
    above(title, add-margin(img))
  end
end

regression-model-coeffs :: (t :: Table, params :: List<String>, response :: String) -> Table
fun regression-model-coeffs(t, params, response) block:
  all-cols = link(response, params)
  check-integrity(t, all-cols)
  # check to make sure the cols exist
  if all-cols.any(lam(col): not(t.column-names().member(col)) end):
    raise(Err.message-exception("One or more of the columns (" + params.join-str(", ") + " or " + response + ") was not found in the table. The valid columns are: " + t.column-names().join-str(", ")))
    # check to make sure the cols are all numeric
  else if all-cols.any(lam(col): not(is-number(t.column(col).get(0))) end):
    raise(Err.message-exception("One or more of the columns (" + params.join-str(", ") + " or " + response + ") does not contain numeric data."))
    # check to make sure we have enough data
  else if params.length() > (t.length() + 1):
    raise(Err.message-exception("Cannot perform regression on these parameters on this table, because a model with " + params.length() + " parameters requires a table with at least " + (params.length() + 1) + " rows"))
  else:
    # generate the coefficients table, replacing Pyret's default "constant" with "intercept"
    Stats.multiple-regression-table(t, params, response)
      .transform-column("coefficient-name", {(v): if v == "constant": "intercept" else: v end})
  end
end

lr-coeffs :: (t :: Table, param :: String, response :: String) -> Table
fun lr-coeffs(t, param, response): regression-model-coeffs(t, [list: param], response) end

regression-model-fun :: (t :: Table, params :: List<String>, response :: String) -> (Row -> Number)
fun regression-model-fun(t, params, response) block:
  # generate the coefficients table
  coeffs = regression-model-coeffs(t, params, response)
  # return a wrapped function, which consumes a row of the 
  # table, extracts the values in explanation-order, and 
  # passes them to the raw function
  lam(r :: Row) block: 
    fun row-missing-col(n): is-none(r.get(n)) end
    when params.any(row-missing-col):
      raise(Err.message-exception("One or more of the columns needed by this model (" + params.join-str(", ") + " and " + response + ") was not found in the table. Are you sure you are fitting the right model to the right data?"))
    end

    fun fold-coeffs(acc, row): 
      if row["coefficient-name"] == "intercept": acc + row["coefficient-value"]
      else: acc + (r[row["coefficient-name"]] * row["coefficient-value"])
      end
    end
    L.foldr(fold-coeffs, 0, coeffs.all-rows())
  end
end

lr-fun :: (t :: Table, param :: String, response :: String) ->  (Row -> Number)
# just a special-case wrapper for multiple-regression-fun, which produces
# a function consuming a row and producing a number
fun lr-fun(t, param, response):
  regression-model-fun(t, [list: param], response)
end

regression-model-code :: (t :: Table, params :: List<String>, response :: String) -> Nothing
fun regression-model-code(t, params, response) block:
  # generate the coefficients table
  coeffs = regression-model-coeffs(t, params, response)
  
  fn-name = params.join-str("-") + "-predictor"

  params-string = if params.length() == 1: "a value for " + params.join-str("")
  else: "values for " + L.take(params.length() - 1, params).join-str(", ") + " and " + params.last()
  end
  
  # return a wrapped function, which consumes a row of the 
  # table, extracts the values in explanation-order, and 
  # passes them to the raw function
  fun fold-code(acc, row): 
    if row["coefficient-name"] == "intercept": 
      acc + num-to-string-digits(row["coefficient-value"], 2)
    else: 
      acc + "(" + num-to-string-digits(row["coefficient-value"], 2) +
      " * " + "r[\"" + row["coefficient-name"] + "\"]" +
      ") + "
    end
  end
  print(
    "# " + fn-name + " :: (r :: Row) -> Number\n" +
    "# Consumes a Row of containing " + params-string + "\n" +
    "# and produces the predicted " + response + "\n" +
    "fun " + fn-name + "(r):\n" + 
    "  " + L.foldr(fold-code, "", coeffs.all-rows()) + "\n" +
    "end")
  nothing
end

#|
lr-code :: (t :: Table, param :: String, response :: String) -> Nothing
# just a special-case wrapper for multiple-regression-fun, which produces
# a function consuming a row and producing a number
fun lr-code(t, param, response):
  regression-model-code(t, [list: param], response)
end
|#

predict-col :: (t :: Table, target-col :: String, predictor :: (Row -> Number)) -> Table
# Move the target column to the end of the table, alongside new 'predicted' and 'error' columns
fun predict-col(t, target-col, predictor) block:
  new-col = target-col + " (predicted)"
  p-table = build-column(t, new-col, predictor)
  if (t.column-names().member(target-col)):
    test-f = {(r): r[new-col] - r[target-col] }
    new-cols = t.column-names()
      .filter({(s): s <> target-col})
      .append([list: target-col, new-col, "Error"])
    p-table.build-column("Error", test-f)
      .select-columns(new-cols)
  else:
    p-table
  end
end


mr-residuals :: (t :: Table, explanations :: List<String>, response :: String, model :: (Row -> Number)) -> List<Number>
fun mr-residuals(t, explanations, response, model) block:
  all-cols = link(response, explanations)
  valid-columns = t.column-names()
  fun missing-column(c): not(valid-columns.member(c)) end
  when all-cols.any(missing-column):
    raise(Err.message-exception("One or more of the columns needed by this model (" + explanations.join-str(", ") + " and " + response + ") was not found in the table. Are you sure you are fitting the right model to the right data?"))
  end
  predictions = map(model, t.all-rows())
  ys = t.column(response)
  map2(lam(y, y-hat): y - y-hat end, ys, predictions)
end

residuals :: (t :: Table, explanation :: String, response :: String, model :: (Number -> Number)) -> List<Number>
fun residuals(t, explanation, response, model):
  fun f(r): model(r[explanation]) end
  mr-residuals(t, [list: explanation], response, f)
end

regression-model-S :: (t :: Table, explanations :: List<String>, response :: String, model :: (Row -> Number)) -> Number
fun regression-model-S(t, explanations, response, model) block:

  # error-checking
  all-cols = link(response, explanations)
  valid-columns = t.column-names()
  fun missing-column(c): not(valid-columns.member(c)) end
  when all-cols.any(missing-column):
    raise(Err.message-exception("One or more of the columns needed by this model (" + explanations.join-str(", ") + " and " + response + ") was not found in the table. Are you sure you are fitting the right model to the right data?"))
  end
  when t.length() < all-cols.length():
    raise(Err.message-exception("Cannot calculate S for this model and function, because a model with " + explanations.length() + " parameters requires a table with at least " + all-cols.length() + " rows"))
  end
  check-integrity(t, all-cols)

  # compute the S-value
  params = explanations.length()
  rows = t.length()
  residuals-sqr = mr-residuals(t, explanations, response, model).map(sqr)
  degrees-of-freedom = rows - params
  num-sqrt(Math.sum(residuals-sqr) / degrees-of-freedom)
end

fun regression-model-s(a, b, c, v):
  raise(Err.message-exception("In statistics, the S-value is always capitalized. Pyret does the same thing! Did you mean to use `regression-model-S`?"))
end

S :: (t :: Table, explanation :: String, response :: String, model :: (Row -> Number)) -> Number
fun S(t, explanation, response, model):
  regression-model-S(t, [list: explanation], response, {(r): model(r[explanation])})
end

fit-model :: (t :: Table, ls :: String, xs :: String, ys :: String, fn :: (Number -> Number)) -> Image
fun fit-model(t, ls, xs, ys, fn) block:
  check-integrity(t, [list: ls, xs, ys])
  labels = get-labels(t, ls)

  # the line below calls S, which does our error-checking
  # wrap the xs in a list, and fn in a row-consuming fn
  s-num = regression-model-S(t, [list: xs], ys, {(r): fn(r[xs])})
  R-sqr-value = Stats.r-squared(t.column(xs), t.column(ys), fn)
  S-str       = easy-num-repr(s-num, 10)
  #r-str       = if (R-sqr-value > 0): easy-num-repr(num-sqrt(R-sqr-value)) else: "N/A" end
  r-sqr-str   = easy-num-repr(R-sqr-value, 10)

  scatter = from-list.scatter-plot(
    ensure-numbers(t.column(xs)),
    ensure-numbers(t.column(ys)))
    .labels(labels)
    .legend("Data")
    .point-size(5)
  padding = (Math.max(t.column(ys)) - Math.min(t.column(ys))) / 100
  fn-plot = from-list.function-plot(fn)
    .color(C.red)
    .legend("Model")
  fun f(r): fn(r[xs]) end
  predictions = map(f, t.all-rows())
  intervals = from-list.interval-chart(
    t.column(xs),
    t.column(ys),
    mr-residuals(t, [list: xs], ys, lam(r :: Row): fn(r[xs]) end))
    .point-size(1)
    .pointer-color(C.green)
    .lineWidth(10)
    .color(C.black)
    .style("sticks")
    .legend("Residuals")
  title-str = "S: " + S-str + "   R²: " + r-sqr-str
  chart = render-charts([list: fn-plot, scatter, intervals]).width(600).height(400)
    .title(title-str)
    .x-axis(xs)
    .y-axis(ys)
    .y-min(num-min(Math.min(t.column(ys)), Math.min(predictions)) - padding)
    .y-max(num-min(Math.max(t.column(ys)), Math.max(predictions)) + padding)
  img = display-chart(chart)
  title = make-title([list:"", ys, "vs.", xs])
  above(title, add-margin(img))
end

# Given a size, produce a normal distribution of that size
# between 0-1 using  Box Muller transform described at
# https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
random-normal-distribution :: (size :: Number) -> List<Number>
fun random-normal-distribution(size) block:
  fun box-muller() block:
    u = (random(100) + 1) / 101
    v = (random(100) + 1) / 101
    num = num-sqrt(-2 * num-log(u)) * num-cos( 2.0 * PI * v )
    (num / 10) + 0.5 # divide and shift to cover (0,1)
  end
  L.range(1, size).map(lam(_): box-muller() end)
end

#####################################################################
## Making tables and graphs from definitions

def-to-table :: (f :: (Number -> Number)) -> Table
# Consumes a function, and produces an x/y table
fun def-to-table(f):
  start = num-random(20) - 10
  step = num-random(5) + 1
  xs = L.range-by(start, start + 100, step)
  ys = xs.map(f)
  [T.table-from-columns: {"x"; xs}, {"y"; ys}]
end

def-to-graph :: (f :: (Number -> Number)) -> Image
# Same as make-table, but makes a line-plot of the resulting table
fun def-to-graph(f) block:
  render-chart(from-list.function-plot(f))
    .x-axis("x")
    .y-axis("y")
    .x-min(-10)
    .x-max(10)
    .y-min(-10)
    .y-max(10)
    .display()
end

table-to-graph :: (t :: Table) -> Image
# Consumes a table, and makes a line-plot from the first 2 columns
fun table-to-graph(t) block:
  cols = t.column-names()
  if (cols.length() < 2):
    raise("The table must have at least two columns")
  else: nothing
  end

  check-integrity(t, [list: cols.get(0), cols.get(1)])

  xs = t.column(cols.get(0))
  ys = t.column(cols.get(1))

  xMin = if (num-round(Math.min(xs)) == num-round(Math.max(xs))):
    num-round(Math.min(xs)) - 5
  else: num-round(Math.min(xs))
  end
  xMax = if (num-round(Math.min(xs)) == num-round(Math.max(xs))):
    num-round(Math.min(xs)) + 5
  else: num-round(Math.max(xs))
  end

  yMin = if (num-round(Math.min(ys)) == num-round(Math.max(ys))):
    num-round(Math.min(ys)) - 5
  else: num-round(Math.min(ys))
  end
  yMax = if (num-round(Math.min(ys)) == num-round(Math.max(ys))):
    num-round(Math.min(ys)) + 5
  else: num-round(Math.max(ys))
  end

  render-chart(from-list.line-plot(xs, ys)).width(600).height(400)
    .x-axis(cols.get(0))
    .y-axis(cols.get(1))
    .x-min(xMin)
    .x-max(xMax)
    .y-min(yMin)
    .y-max(yMax)
    .display()
end


#####################################################################
## String Munging

word-frequency :: String -> Table
fun word-frequency(txt) block:

  fun isAsciiLetter(cp :: Number):
    ((cp > 64) and (cp < 91)) or ((cp > 96) and (cp < 123))
  end

  fun lettersOnly(word :: String):
    string-from-code-points(
      string-explode(word)
        .map(string-to-code-point)
        .filter(isAsciiLetter))
  end

  # Capitalize and split the the string into words, strip each
  # word of any non-ascii-letter characters, filter out any
  # words that are now just the empty string, and sort
  ascii-words = string-split-all(string-to-upper(txt), " ")
    .map(lettersOnly)
    .filter(lam(str): str <> "" end)
    .sort()

  # Walk through the (sorted) words, creating a tuple containing a
  # unique-word list and a list of counts
  unique-counts = L.foldl(
    lam(base, val) block:
      {labels; counts} = base
      if labels.member(val):
        {labels; counts.set(0, counts.get(0) + 1)}
      else:
        {link(val, labels); link(1, counts)}
      end
    end,
    {[list:]; [list:]},
    ascii-words
    )

  # Make a table from those two lists, then add a column that counts characters
  t = T.table-from-column("word", unique-counts.{0})
    .add-column("count", unique-counts.{1})
  t.build-column("characters", lam(r): string-length(r["word"]) end)
    .order-by("count", false)
end

#####################################################################
# used by shapes starter file
draw-shape :: Row -> Image
fun draw-shape(r):
  if r["name"] == "ellipse": ellipse(50, 100, "solid", r["color"])
  else if r["name"] == "circle": circle(50, "solid", r["color"])
  else: regular-polygon(30, r["corners"], "solid", r["color"])
  end
end


#################################################################################
# Live Survey Functions
fun live-display(gsheetID :: String, sheet-name :: String, columns :: List<String>, visualize)  -> Image block:
  fun get-table(t):
    sheet = load-spreadsheet(gsheetID).sheet-by-name(sheet-name, true)
    builtins.open-table(sheet.load(raw-array-from-list(columns), [raw-array: ]))
  end
  r = reactor:
    init: get-table(nothing),
    to-draw: visualize,
    seconds-per-tick: 2,
    on-tick: get-table
  end
  r.interact()
  visualize(get-table(nothing))
end


# live-survey :: (String, String, List<String> :: (Any -> Image)
fun live-survey(gsheetID, sheet-name, columns, visualize) block:
  live-display(gsheetID, sheet-name, columns, visualize)
end


## OUTLIER TOOLS ##########################################

q1 :: (t :: Table, col :: String) -> Number
fun q1(t, col) block:
  check-integrity(t, [list: col])
  values = t.get-column(col).sort()
  first-half = values.split-at(num-floor(values.length() / 2)).prefix
  Stats.median(first-half)
end


q3 :: (t :: Table, col :: String) -> Number
fun q3(t, col) block:
  check-integrity(t, [list: col])
  values = t.get-column(col).sort()
  second-half = values.split-at(num-ceiling(values.length() / 2)).suffix
  Stats.median(second-half)
end

compute-outliers :: (t :: Table, col :: String) -> Table
# consumes a table and a column, calculates both the lower boundary and upper boundary (fences), creates a new column called "is-outler" that is populated with "low", "high" and "no"
# (Credit to Jennifer Braun, CSPdWeek 2019)
fun compute-outliers(t, col) block:
  check-integrity(t, [list: col])
  lower-boundary = q1(t, col) - (1.5 * (q3(t, col) - q1(t, col)))
  upper-boundary = q3(t, col) + (1.5 * (q3(t, col) - q1(t, col)))
  t.build-column("is-outlier",
    (lam(r):
        ask:
          | (r[col] < lower-boundary) then: "low"
          | (r[col] > upper-boundary) then: "high"
          | otherwise: "no"
        end
      end))
end


outliers :: (t :: Table, col :: String) -> Table
# consumes a table and a column, and returns a table for which every row is an outlier
# (for that column)
fun outliers(t, col):
  compute-outliers(t, col).filter(lam(r): r["is-outlier"] <> "no" end).drop("is-outlier")
end

remove-outliers :: (t :: Table, col :: String) -> Table
# consumes a table and a column, calculates both the lower boundary and upper boundary (fences), and removes any rows that are beyond the fence
# (Credit to Jennifer Braun, CSPdWeek 2019)
fun remove-outliers(t, col):
  compute-outliers(t, col)
    .filter(lam(r): r["is-outlier"] == "no" end)
    .drop("is-outlier")
end

## TABLE MUNGING ########################################
row-id :: (t :: Table, id :: String) -> Row
fun row-id(t, id):
  id-col = t.column-names().get(0)
  matching-rows = t.filter(lam(r): r[id-col] == id end)
  if (matching-rows.length() > 1):
    raise(Err.message-exception("The identifier column should contain unique IDs, but this ID matched more than one row"))
  else if (matching-rows.length() == 0) :
    raise(Err.message-exception("No rows have this ID in their identifier column (did you check spelling and capitalization?"))
  else: matching-rows.row-n(0)
  end
end

split-and-reduce :: (
  t :: Table,
  col-to-split :: String,
  col-to-reduce :: String,
  reducer :: (Table, String -> Any)
  ) -> Table
fun split-and-reduce(t, col-to-split, col-to-reduce, reducer) block:
  fun wrapped-reducer(r):
    cases(Eth.Either) run-task(lam():
            reducer(r["subtable"], col-to-reduce)
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
  group(t, col-to-split)
    .build-column("result", wrapped-reducer)
    .drop("subtable")
end

first-n-rows :: (t :: Table, n :: Number) -> Table
fun first-n-rows(t, n):
  T.table-from-rows.make(raw-array-from-list(t.all-rows().take(n)))
end

last-n-rows :: (t :: Table, n :: Number) -> Table
fun last-n-rows(t, n):
  T.table-from-rows.make(raw-array-from-list(t.all-rows().reverse().take(n).reverse()))
end


fun group(tab, col):
  values = Sets.list-to-list-set(tab.get-column(col)).to-list()
  for fold(shadow grouped from table: value, subtable end, v from values):
    grouped.stack(table: value, subtable
        row: v, tab.filter-by(col, {(val): val == v})
      end)
  end
end

fun count(tab, col):
  g = group(tab, col).build-column("frequency", {(r): r["subtable"].length()}).drop("subtable")
  if is-boolean(g.column("value").get(0)): g
  else: order g: value ascending end
  end
    .rename-column("value", col)
end

#|
   fun count-many(tab, cols):
  for fold(shadow grouped from table: col, subtable end, c from cols):
    grouped.stack(table: col, subtable
        row: c, count(tab, c)
      end)
  end
   end
|#

fun group-and-subgroup(t :: Table, col :: String, subcol :: String) block:
  subgroups = Sets.list-to-set(t.get-column(subcol))
  tab = group(t, col)
    .rename-column("value", "group")
    .build-column(
    "data",
    # take a count of the subgroups, then see which subgroups are missing
    # for each one, add a row with a count of zero. Then order the rows
    # and extract the count as a list
    lam(r) block:
      segments = count(r["subtable"], subcol)
      missing = subgroups.difference(Sets.list-to-set(segments.get-column(subcol)))
      missing.fold(
        lam(table, subgroup):
          table.add-row([T.raw-row: {subcol; subgroup}, {"frequency"; 0}])
        end,
        segments)
        .build-column("sortable", lam(shadow r): to-repr(r[subcol]) end)
        .order-by("sortable", true)
        .get-column("frequency")
    end)
  # sort groups alphabetically
  sort(tab, "group", true)
end


# pivot-row :: r :: Row -> Table
fun pivot-row(r) block:

  # get-val :: (col :: String) -> Any
  fun get-val(col): r[col] end

  columns = r.get-column-names()
  values = columns.map(get-val)
  [T.table-from-columns:
    {"labels"; columns},
    {"values"; values}
  ]
end



fun transpose(t :: Table) block:
  cols = t.column-names()
  row-names = cols.drop(1)
  first-col = cols.get(0)
  # use the old header row as the first column in the new table
  var new_t = T.table-from-column(first-col, row-names)

  split = split-at(1, t.all-columns())
  new-cols = split.prefix.get(0)
  old-rows = split.suffix

  # for each column in our new table, mine the old rows for their values
  map_n(lam(n, col) block:
      new_t := new_t.add-column(col, map_n(lam(m, v): old-rows.get(m).get(n) end, 0, row-names))
    end,
    0,
    new-cols)
  new_t
end

fun random-rows(t, n):
  doc: ```
       if n <<< t.length(), it would be good to sample the rows with row-n and
       build up a table from that rather than doing this process, which is linear
       in the universe size. if n is a proportional to t.length(),
       then this works pretty well.
       ```

  fun filter-n(tabl, pred):
    var i = 0
    tabl.filter(lam(x) block:
        result = pred(i, x)
        i := i + 1
        result
      end)
  end

  fun make-sample-selections(shadow n :: Number, u :: Number) -> {Boolean; SD.StringDict<Boolean>} block:
    doc: ```
         Key idea: build a dictionary that's either "positive" (keep these keys)
         or "negative" (drop these keys). Do this according to if we want most
         of the keys to stay (use a negative map) or most to go (use a positive
         map). There isn't a good, fast way to remove from a table by index right
         now, so this plus filter is best and actually reasonably performant.
         ```
    when n > u:
      raise(Err.message-exception("make-sample-selections: num-samples too large"))
    end
    fun help(num-samples-remaining-to-get, dict-so-far):
      if num-samples-remaining-to-get == 0: dict-so-far
      else:
        r = num-random(u)
        k = num-to-string(r)
        if dict-so-far.has-key(k):
          help(num-samples-remaining-to-get, dict-so-far)
        else:
          updated = dict-so-far.set(k, true)
          help(num-samples-remaining-to-get - 1, updated)
        end
      end
    end
    if n < (u / 2):
      {true; help(n, [SD.string-dict:])}
    else:
      {false; help(u - n, [SD.string-dict:])}
    end
  end

  {keep; to-change} = make-sample-selections(n, t.length())
  filter-n(t, lam(index, _):
      k = to-string(index)
      #| could also be written keep == to-change.has-key(k),
      but I find that difficult to grok |#
      if keep: to-change.has-key(k)
      else: not(to-change.has-key(k))
      end
    end)
end

fun make-random-table(num-rows) block:
  var t = table: a end
  for each(i from L.range(0, num-rows)):
    t := t.add-row(t.row(num-random(num-rows)))
  end
  t
end

fun row-to-list(r):
  r.get-column-names().map(r[_])
end



## INFERENCE ##########################################

pop-variance :: (t :: Table, col :: String) -> Number
fun pop-variance(t, col) block:
  check-integrity(t, [list: col])
  _mean = Stats.mean(ensure-numbers(t.column(col)))
  shadow t = t.build-column("sq-diff", lam(r): num-sqr(r[col] - _mean) end)
  Math.sum(ensure-numbers(t.column("sq-diff"))) / t.length()
end

sample-variance :: (t :: Table, col :: String) -> Number
# sample variance for ungrouped data
fun sample-variance(t, col) block:
  check-integrity(t, [list: col])
  _mean = Stats.mean(ensure-numbers(t.column(col)))
  shadow t = t.build-column("sq-diff", lam(r): num-sqr(r[col] - _mean) end)
  Math.sum(ensure-numbers(t.column("sq-diff"))) / (t.length() - 1)
end



paired-t :: (t :: Table, col1 :: String, col2 :: String) -> Number
fun paired-t(t, col1, col2) block:
  check-integrity(t, [list: col1, col2])
  shadow t = t.build-column("diff", lam(r): r[col2] - r[col1] end)
  mean1 = Stats.mean(ensure-numbers(t.column(col1)))
  mean2 = Stats.mean(ensure-numbers(t.column(col2)))
  sdiff = stdev(t, "diff")
  n = t.length()
  df = n - 1
  (mean1 - mean2) / (sdiff / num-sqr(n))
end

eq-variance-t :: (t :: Table, col1 :: String, col2 :: String) -> Number
fun eq-variance-t(t, col1, col2) block:
  check-integrity(t, [list: col1, col2])
  shadow t = t.build-column("diff", lam(r): r[col2] - r[col1] end)
  mean1 = Stats.mean(ensure-numbers(t.column(col1)))
  mean2 = Stats.mean(ensure-numbers(t.column(col2)))
  var1 = sample-variance(t, col1)
  var2 = sample-variance(t, col2)
  n1 = t.length()
  n2 = t.length()
  (mean1 - mean2) / num-sqrt((var1 / n1) + (var2 / n2))
end

uneq-variance-t :: (t :: Table, col1 :: String, col2 :: String) -> Number
fun uneq-variance-t(t, col1, col2) block:
  check-integrity(t, [list: col1, col2])
  shadow t = t.build-column("diff", lam(r): r[col2] - r[col1] end)
  mean1 = Stats.mean(ensure-numbers(t.column(col1)))
  mean2 = Stats.mean(ensure-numbers(t.column(col2)))
  var1 = sample-variance(t, col1)
  var2 = sample-variance(t, col2)
  n1 = t.length()
  n2 = t.length()
  df = n1 + n2 + -2
  dfs-and-sq-vars = (((n1 - 1) * num-sqr(var1)) + ((n2 - 1) * num-sqr(var2)))
  (mean1 - mean2) / ((dfs-and-sq-vars / df) * num-sqrt((1 / n1) + (1 / n2)))
end

fun make-noisy-table(fn, min, max, noise-level) block:
  samples = L.range-by(min, max, Math.max([list: (max - min) / 500]))
  defined-points = samples.foldr(lam(sample, points): 
      cases (Option) maybe-get-value(lam(): fn(sample) end):
        | some(y) => link({sample;y}, points)
        | none => points
      end
    end, empty)
  xs = defined-points.map(lam(t): t.{0} end)
  fn_ys = defined-points.map(lam(t): t.{1} end)
  noise = random-normal-distribution(xs.length() + 1)
  ys = map2(lam(x, y): x + ((noise-level * (y - 0.5))) end, fn_ys, noise)
  [T.table-from-columns: {"x"; xs}, {"y"; ys}]
end

fun make-noisy-scatter-chart(fn, min, max, noise-level) block:
  xs = L.range-by(min, max, Math.max([list: (max - min) / 500]))
  fn_ys = xs.map(fn)
  noise = random-normal-distribution(xs.length() + 1)
  ys = map2(lam(x, y): x + ((noise-level * (y - 0.5))) end, fn_ys, noise)
  render-chart(from-list.scatter-plot(xs, ys))
end

################# UTILITY FUNCTIONS ###########################

fun maybe-get-value(f :: Function):
  cases (Eth.Either) run-task({(): f()}):
    | left(v) => some(v)
    | right(v) => none
  end
end

# courtesy of Ben Lerner
# first, we define a data structure that we can run cases on...
data TaggedFunction:
  | one(f :: (Number -> Number))
  | two(f :: (Number, Number -> Posn))
  | three(f :: (Number, Number, String -> Posn))
end

# then, we use exceptions (!) to figure out which structure to return..
fun guess-arity(f :: Function) -> TaggedFunction:
  cases (Eth.Either) run-task({(): f(0) }):
    | left(v) => one(f)
    | right(v) =>
      err = exn-unwrap(v)
      if Err.is-arity-mismatch(err):
        cases (Eth.Either) run-task({(): f(0, 0)}):
          | left(shadow v) => two(f)
          | right(shadow v) =>
            shadow err = exn-unwrap(v)
            if Err.is-arity-mismatch(err):
              cases (Eth.Either) run-task({(): f(0, 0, 0)}):
                | left(shadow v) => three(f)
                | right(shadow v) =>
                  shadow err = exn-unwrap(v)
                  if Err.is-arity-mismatch(err):
                    raise("Unknown function arity")
                  else:
                    three(f)
                  end
              end
            else:
              two(f)
            end
        end
      else:
        one(f)
      end
  end
end


shadow translate = put-image
shadow dilate = scale


##################################################################################
# Image Helpers

# luminance :: Color -> Number
# computes the perceptual luminance of a pixel using the
# standard ITU-R BT.709 coefficients
fun luminance(c) -> Number:
  (0.2126 * c.red) + (0.7152 * c.green) + (0.0722 * c.blue)
end

# Convert an RGB color to a grayscale intensity (0-255)
# Uses the standard luminance-weighted formula
fun color-to-gray(c :: C.Color) -> Number:
  num-round(
    (0.299 * c.red) +
    (0.587 * c.green) +
    (0.114 * c.blue)
    )
end

# pixels-to-image :: (List<Color>, Number, Number) -> Image
# shared helper that converts a pixel list back into an image,
# centering the pinhole
fun pixels-to-image(pixels, width, height) -> Image:
  color-list-to-image(pixels, width, height, num-round(width / 2), num-round(height / 2))
end

# dominant-rgb-colors :: Image -> String
# Given an image, it to a string of space-separated color names 
# ("red", "green", or "blue"), representing the dominant channel 
# of each non-transparent pixel
fun dominant-rgb-colors(img :: Image) -> String block:
  fun dominant-color(pixel) -> String:
    if (pixel.red == pixel.green) and (pixel.red == pixel.blue): ""
    else if (pixel.red >= pixel.green) and (pixel.red >= pixel.blue): "red"
    else if (pixel.green >= pixel.red) and (pixel.green >= pixel.blue): "green"
    else: "blue"
    end
  end
  image-to-color-list(img)
    .filter(lam(pixel): pixel.alpha > 0 end)
    .map(dominant-color)
    .filter(lam(s): s <> "" end)
    .join-str(" ")
end

# invert :: Image -> Image
# inverts the RGB channels of each pixel, preserving alpha
fun invert(img :: Image) -> Image:
  width  = image-width(img)
  height = image-height(img)
  pixels-to-image(
    image-to-color-list(img).map(lam(p):
        make-color(255 - p.red, 255 - p.green, 255 - p.blue, p.alpha)
      end),
    width, height)
end

# grayscale :: (Image) -> Image
# produces an identical image in which all pixels
# have been converted to grayscale
fun grayscale(img :: Image) -> Image:
  pixels-to-image(
    image-to-color-list(img).map(lam(p) block:
        g = color-to-gray(p)
        make-color(g, g, g, p.alpha)
      end),
    image-width(img),
    image-height(img))
end

greyscale = grayscale

# Consumes an image and computes the average luminance
# round to 10 digits and use exact
fun image-luminance(img :: Image) -> Number:
  avg-luminance = Stats.mean(image-to-color-list(img).map(luminance))
  num-exact(num-round-to(avg-luminance, 10))
end

# Consumes an image and computes the entropy
# round to 10 digits and use exact
fun image-entropy(img :: Image) -> Number block:
  # Sum -p*log2(p) over all keys in the frequency table
  fun entropy-sum(keys :: List, freq :: SD.StringDict, total, acc) -> Number:
    cases (List) keys:
      | empty => acc
      | link(k, rest) =>
        p = freq.get-value(k) / total
        contribution = p * (num-log(p) / num-log(2))
        entropy-sum(rest, freq, total, acc - contribution)
    end
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

  pixels = image-to-color-list(img)
  total = pixels.length()
  freq = build-freq(pixels, [SD.string-dict:])
  entropy = entropy-sum(freq.keys().to-list(), freq, total, 0)
  num-exact(num-round-to(entropy, 10))
end

# combine-images :: (Image, Image, (Color, Color -> Color)) -> Image
# 1) Norms the image sizes by overlaying them onto a transparent
# rectangle drawn from their max width and height
# 2) Merges two normed images pixel-by-pixel using the given combinator
fun combine-images(
    img1 :: Image, 
    img2 :: Image, 
    combinator :: (C.Color, C.Color -> C.Color)
    ) -> Image:
  width  = num-max(image-width(img1),  image-width(img2))
  height = num-max(image-height(img1), image-height(img2))
  bg = rectangle(width, height, "solid", "transparent")
  normed_img1 = overlay(center-pinhole(img1), bg)
  normed_img2 = overlay(center-pinhole(img2), bg) 
  combined-pixels = for map2(
      c1 from image-to-color-list(normed_img1), 
      c2 from image-to-color-list(normed_img2)):
    combinator(c1, c2)
  end
  pixels-to-image(combined-pixels, width, height)
end

# lighter :: (Image, Image) -> Image
# produces an image where each pixel is whichever of the two
# input pixels has higher luminance. transparent pixels pass through.
fun lighter(img1 :: Image, img2 :: Image) -> Image:
  combine-images(img1, img2, lam(c1, c2):
      if c1.alpha == 0: c2
      else if c2.alpha == 0: c1
      else if luminance(c1) >= luminance(c2): c1
      else: c2
      end
    end)
end

# darker :: (Image, Image) -> Image
# produces an image where each pixel is whichever of the two
# input pixels has lower luminance. transparent pixels pass through.
fun darker(img1 :: Image, img2 :: Image) -> Image:
  combine-images(img1, img2, lam(c1, c2):
      if c1.alpha == 0: c2
      else if c2.alpha == 0: c1
      else if luminance(c1) <= luminance(c2): c1
      else: c2
      end
    end)
end

# blend-images :: (Image, Image) -> Image
# averages the RGB and alpha channels of each pair of pixels.
# transparent pixels in either image show through to the other.
# handles images of different sizes by padding both to the same dimensions.
shadow blend-images = lam(img1 :: Image, img2 :: Image) -> Image:
  combine-images(img1, img2, lam(c1, c2):
      if c1.alpha == 0: c2
      else if c2.alpha == 0: c1
      else:
        make-color(
          num-round((c1.red   + c2.red)   / 2),
          num-round((c1.green + c2.green) / 2),
          num-round((c1.blue  + c2.blue)  / 2),
          num-round((c1.alpha + c2.alpha) / 2))
      end
    end)
end

# compute symmetry along the horizontal and vertical axes
# 1 = totally symmetric, 0 = not at all symmetric
fun image-symmetry-vertical(img :: Image) -> Number:
  num-exact(num-round-to(
      1 - ((~0 + images-difference(img, flip-horizontal(img)).v) / 255),
      10))
end
fun image-symmetry-horizontal(img :: Image) -> Number:
  num-exact(num-round-to(
      1 - ((~0 + images-difference(img, flip-vertical(img)).v) / 255),
      10))
end

# Counts pixels in `img` where the given channel ("red", "green", or "blue")
# is strictly the largest of the three channel values
fun count-dominant-pixels(img :: Image, channel :: String) -> Number:
  # Returns true if `a` is strictly greater than both `b` and `c`
  fun is-dominant(a :: Number, b :: Number, c :: Number) -> Boolean:
    (a > b) and (a > c)
  end

  color-list = I.image-to-color-list(img)
  for fold(acc from 0, c from color-list):
    r = c.red
    g = c.green
    b = c.blue
    dominant = ask:
      | channel == "red"   then: is-dominant(r, g, b)
      | channel == "green" then: is-dominant(g, r, b)
      | channel == "blue"  then: is-dominant(b, r, g)
      | otherwise: false
    end
    if dominant: acc + 1 else: acc end
  end
end

fun image-red-pixels(img :: Image):   count-dominant-pixels(img, "red")   end
fun image-green-pixels(img :: Image): count-dominant-pixels(img, "green") end
fun image-blue-pixels(img :: Image):  count-dominant-pixels(img, "blud")  end


################################################################
###################### TEXT TOOLS ##################


num-words :: String -> Number
fun num-words(txt):
  string-split-all(txt, " ").filter({(w): w <> ""}).length()
end


num-sentences :: String -> Number
fun num-sentences(txt): string-split-all(txt, ". ").length() end

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

fun sort-strings-ci(lst :: List<String>) -> List<String>:
  lst.sort-by(
    {(a, b): string-to-lower(a) < string-to-lower(b)}, 
    {(a, b): string-to-lower(a) == string-to-lower(b)})
end

################################################################
###################### INEQUALITIES SIMULATOR ##################

fun draw-inequality(points, f, msg-img) block:

  # some constants for drawing, intervals, etc
  STRIP-WIDTH = 400
  STRIP-HEIGHT = 30
  tri = rotate(90, triangle(10, "solid", "black"))
  num-intervals = 10
  c1 = make-color(100, 100, 255, 0.5)
  strip = rectangle(STRIP-WIDTH + 48, STRIP-HEIGHT, "outline", "transparent")
  inequalities-bg = overlay(rectangle(STRIP-WIDTH, 2, "solid", "black"), strip)
  axis = translate(flip-horizontal(tri),
    STRIP-WIDTH + 38, STRIP-HEIGHT / 2,
    translate(tri, 10, STRIP-HEIGHT / 2, inequalities-bg))

  fun num-to-mark(n):
    if num-is-integer(n): num-to-string(n)
    else: num-to-string-digits(n, 2) end
  end

  # given a textcolor, a fn to draw the point, and a projection fn,
  # produce a function that consumes a point and an image, then draws
  # a dot of that color
  fun dot-builder(draw-point, project, shadow points, base):
    points.foldl(
      lam(p, img):
        translate(draw-point(p), project(p) + 24, STRIP-HEIGHT / 2, img)
      end,
      base)
  end

  # build a strip of labeled points
  fun label-builder(project, shadow points, alignment, c):
    points.foldl(
      lam(p, img):
        translate(
          overlay-align("center", alignment,
            rotate(90, text(num-to-mark(p), 10, c)),
            square(30, "solid", "transparent")),
          project(p) + 24, STRIP-HEIGHT / 2,
          img)
      end,
      strip)
  end

  # given an inequality fn and a reverse-projection fn, test every pixel
  # on a 600px range and mark "true" pixels as transparent blue
  fun draw-shade(rProject, c):
    range-by(0, STRIP-WIDTH, 2).foldl(lam(p, img):
        shadow color = if f(rProject(p)): c else: "transparent" end
        beside(img, rectangle(2, 15, "solid", color))
      end,
      rectangle(0,0,"solid","transparent"))
  end

  # find the start and stop of the range
  start = Math.min(points)
  stop = Math.max(points)
  # given one of the points on the range, project to pixels on the axis
  fun project(p): (p - start) * (STRIP-WIDTH / (stop - start)) end
  # given a pixel on the axis, reverse-project back to a point on the range
  fun rProject(p): (p / (STRIP-WIDTH / (stop - start))) + start end
  # make a list of all the interval coordinates
  intervals = range-by(start, stop, (stop - start) / num-intervals)
  # make a strip containing all those intervals
  intervals-strip = label-builder(project, intervals, "top", "darkgray")
  # make a strip containing all the points
  points-strip = label-builder(project, points, "bottom", "black")
  # starting with the blank axis, add the shade...
  axis-strip = translate(draw-shade(rProject, c1),
    (STRIP-WIDTH + 50) / 2, STRIP-HEIGHT / 2, axis)
  # add the interval dots
  black-dots-strip = dot-builder(lam(p): circle(2, "solid", "black") end, project, intervals, axis-strip)
  # add the points
  dots-strip = dot-builder(lam(p): translate(
        text(if f(p): "T" else: "F" end, 10, "black"),
        10, 8,
      circle(10, "solid", if f(p): "green" else: "red" end)) end,
    project, points, black-dots-strip)
  when (points.length() <> 8):
    raise("the list must contain exactly 8 points")
  end
  above-list([list: strip, points-strip, dots-strip, intervals-strip, msg-img])
end

# given a list of numbers and an inequality function,
# check to see if the list contains 8 elements, then graph
# the inequality and the points on a numberline
# report back which points passed
fun inequality(f, points):
  passed = points.foldl(lam(p, shadow count): (if f(p): count + 1 else: count end) end, 0)
  msg-img = if (passed == 4):
    text(" ", 20, "green")
  else: text("Challenge yourself: Find 4 true examples and 4 false", 20, "red")
  end
  draw-inequality(points, f, msg-img)
end

fun or-union(f1, f2, points):
  msg-img = text("All regions shaded blue are part of the solution", 20, "blue")
  overlay-align(
    "center", "top",
    text("UNION", 20, "black"),
    draw-inequality(points, lam(x): f1(x) or f2(x) end, msg-img))
end

fun and-intersection(f1, f2, points):
  start = Math.min(points)
  stop = Math.max(points)
  f = lam(x): f1(x) and f2(x) end
  has-intersection = L.any(f, range-by(0, 600, 1))
  msg-img = if has-intersection:
    text("All regions shaded blue are part of the solution", 20, "blue")
  else: text("No solution exists within this range!", 20, "blue")
  end
  overlay-align(
    "center", "top",
    text("INTERSECTION", 20, "black"),
    draw-inequality(points, lam(x): f1(x) and f2(x) end, msg-img))
end



################################################################
############### PERMUTATIONS AND COMBINATIONS ##################
factorial :: (n :: NumNonNegative) -> Number
fun factorial(n):
  if (n <= 1): 1
  else: n * factorial(n - 1)
  end
end

permute-wo-replace :: <A>(items :: L.List<A>, choose :: Number) -> L.List<List<A>>
fun permute-wo-replace(items, choose):
  if items.length() == 0: [list:]
  else if choose == 0: [list:]  # nothing to choose -> empty list
  else if choose == 1: items.map(lam(e): [list: e] end)
  else:
    items.foldl(lam(e, acc):
        rest = permute-wo-replace(items.remove(e), choose - 1).map(lam(p):
          link(e, p) end)
        acc.append(rest)
      end,
      [list:])
  end
end


permute-w-replace :: <A>(items :: L.List<A>, choose :: Number) -> L.List<List<A>>
fun permute-w-replace(items, choose):
  if items.length() == 0: [list:]
  else if choose == 0: [list:]
  else if choose == 1: items.map(lam(e): [list: e] end)
  else:
    items.foldl(lam(e, acc):
        rest = permute-w-replace(items, choose - 1).map(lam(p):
          link(e, p) end)
        acc.append(rest)
      end,
      [list:])
  end
end

combine-wo-replace :: <A>(items :: L.List<A>, choose :: Number) -> L.List<List<A>>
# from https://rosettacode.org/wiki/Combinations#Pyret
fun combine-wo-replace(items, choose):
  if items.length() < choose:
    raise(Err.message-exception("The list must be at least as long as the number of choices"))
  else if items.length() == choose: [list: items]
  else if choose == 1: items.map(lam(e): [list: e] end)
  else:
    # The main resursive step here is to consider
    # all the combinations of the list that have the
    # first element (aka head) and then those that don't
    # don't.
    cases(List) items:
      | empty => [list:]
      | link(first, rest) =>
        # All the subsets of our list either include the
        # first element of the list or they don't.
        with-first = combine-wo-replace(rest, choose - 1).map(
          lam(c): link(first, c) end)
        without-first = combine-wo-replace(rest, choose)
        with-first.append(without-first)
    end
  end
end

render-list :: (lst :: L.List) -> Image
fun render-list(lst):
  lst-imgs = lst.map(lam(l):
      elt-imgs = l.map(lam(e):
          if is-image(e): e
          else if is-string(to-repr(e)): text(e, 12, "black")
          else: to-repr(e)
          end
        end)
      beside-list(elt-imgs)
    end)
  unspoken-img(above-list(lst-imgs))
end

fun whats-missing(answer, test):
  answer-set = Sets.list-to-set(answer)
  test-set = Sets.list-to-set(test)
  diff = answer-set.difference(test-set)
  if diff.size() > 0: diff.to-list()
  else: "You got them all!"
  end
end

fun unspoken-img(img): color-list-to-image(image-to-color-list(img), image-width(img), image-height(img), image-pinhole-x(img), image-pinhole-y(img)) end


#########################################################
# Image transformation functions

# print-imgs :: (img-lst :: L.List<Image>) -> Image
# maximize height and add padding to each image, then
# sort them in order of decreasing heights
# stick them together until we hit 500px,
# then start a new row
fun print-imgs(img-lst) block:

  # how much padding to put around each image (in px)
  padding = 10

  fun img-compare(img1, img2):
    (image-height(img1) >= image-height(img2)) and
    (image-width(img1) > image-width(img2))
  end
  fun img-eq(img1, img2):
    image-height(img1) == image-height(img2)
  end

  # if an image is wider than it is tall, rotate it 90°
  fun maximize-height(img):
    if (image-height(img) > image-width(img)): img
    else: rotate(90, img)
    end
  end
  # Add an extra padding on either side an image
  fun add-padding(img):
    w = image-width(img) + padding
    h = image-height(img) + padding
    overlay(img, rectangle(w, h, "solid", "transparent"))
  end
  fun add-dimensions(img):
    w = image-width(img)
    h = image-height(img)
    wS = num-to-string(w)
    hS = num-to-string(h)
    txt = text([list:wS, "x", hS].join-str(""), 100, "black")
    scaled-txt = if (image-width(img) > image-height(img)):
      scale(0.5, scale(w / image-width(txt), txt))
    else:
      rotate(90, scale(0.5, scale(w / image-height(txt), txt)))
    end
    translate(
      scaled-txt,
      (w / 2),
      (h / 2),
      img)
  end


  # if it's the first image, just add it
  # otherwise grab the last row, and see if we can add the image
  # if not, start a new row
  fun processor(img, acc):
    if (acc.length() == 0): acc.push(img)
    else:
      var split = L.split-at(1,acc)
      var lastRow = split.prefix.last()
      if ((image-width(lastRow) + image-width(img)) > 500):
        acc.push(img)
      else:
        split.suffix.push(beside(lastRow,img))
      end
    end
  end

  img-lst
    .map(maximize-height)
    .sort-by(img-compare, img-eq)
    .map(add-dimensions)
    .map(add-padding)
    .foldl(processor, [list:])
    .foldl(lam(img, acc): below(img, acc) end,
    square(padding,"solid","transparent"))
end


####################################################################
# Folded in from ai-library.arr (formerly a separate 'core++' file
# that layered AI-specific helpers on top of this one). Everything
# below was originally defined there.
####################################################################

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
  add-col(t, doc-col, "DOMINANT-RGB-COLORS", dominant-rgb-colors) 
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

fun find-punct-list(s :: String) -> List<String>:
  string-explode(s)
    .filter(lam(x): not(is-non-punct(x)) end)
    .filter(is-non-empty-string)
end

fun remove-stop-words(s :: String) -> String:
  string-split-all(s, " ")
    .filter({(w): not(stop-words.member(w))})
    .filter(is-non-empty-string)
    .join-str(" ")
end

fun normalize-text-table(t :: Table, col :: String) -> Table:
  t.transform-column(
    col,
    {(txt): remove-stop-words(remove-punct(lowercase(txt)))}
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
fun search-by-tag(t, tags :: List<String>) block:
  cols = get-unrestricted-cols(t.row-n(0))

  # For each tag: build its centroid, score every row by angle-similarity,
  # and accumulate into a running "score" column.
  fun add-tag-score(tag, shadow t):
    matching-ids = tagged-ids(t, tag)
    t-w-centroid = add-centroid(t, "TAG", matching-ids)
    scored = angle-similarity(t-w-centroid, "TAG CENTROID", cols)
      .filter({(r): r["ID"] <> "TAG CENTROID"})
    if t.column-names().member("score"):
      scored.build-column("score2", {(r): r["score"] + r["angle-similarity"]})
        .drop("angle-similarity")
        .drop("score")
        .rename-column("score2", "score")
    else:
      scored.rename-column("angle-similarity", "score")
    end
  end

  # IDs of rows directly tagged with at least one of the search tags
  matched-ids = tags.foldl(lam(tag, acc): acc + tagged-ids(t, tag) end, [list: ])

  scored = tags.foldl(add-tag-score, t)

  direct = scored.filter({(r): matched-ids.member(r["ID"])}).order-by("score", true)
  rest   = scored.filter({(r): not(matched-ids.member(r["ID"]))}).order-by("score", true)

  direct.stack(rest).drop("score")
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
# The library offers three levels of comparison, in which all 
# rows are ranked according to their similarity to a given row ID
# 
# The four comparison approaches are:
#
# 1. simple-similarity — perfect equality
# 2. cosine-similarity — a continuous score from 0 to 1 measuring
#                        how similar the word frequency vectors are
# 3. angle-similarity  — converts cosine similarity to an angle (0-90°),
#                        where 0° means identical and 90° means nothing
#                        in common.
# 4. all-cols-similarity — same as angle similarity, but auto-chooses the cols
#
# All four algorithms have been hand-tweaked to pull the row with the 
# given ID to the top, making that row "most similar" to itself even if
# other rows have the exact same score.
################################################################

fun pull-seed-to-top(t :: Table, id) -> Table block:
  t-w-seed = t.filter({(r): r["ID"] == id})
  rest     = t.filter({(r): r["ID"] <> id})
  t-w-seed.stack(rest)
end

# simple-similarity: true iff the specified cols of the two rows 
# are identical
fun simple-similarity(t :: Table, id, cols :: List<String>) block:
  when not(t.column("ID").member(id)):
    raise(Err.message-exception("Could not find ID '" + id + "' in this table" ))
  end
  fun helper(r1 :: Row, r2 :: Row) -> Number block:
    vals1 = cols.map({(c): r1[c]})
    vals2 = cols.map({(c): r2[c]})
    if (vals1 == vals2): 1 else: 0 end
  end
  compare-to = t.filter({(r): r["ID"] == id}).row-n(0)
  fun compare-row(r): helper(r, compare-to) end
  results = t.build-column("simple-similarity", compare-row).order-by("simple-similarity", false)
  pull-seed-to-top(results, id)
end

# distance-similarity: returns the euclidean distance between
# points defined by the cols
fun distance-similarity(t :: Table, id, cols :: List<String>) block:
  when not(t.column("ID").member(id)):
    raise(Err.message-exception("Could not find ID '" + id + "' in this table" ))
  end

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
  results = t.build-column("distance-similarity", compare-row).order-by("distance-similarity", true)
  pull-seed-to-top(results, id)
end

# all-cols-similarity: returns 1 if the two bags contain the same words
# with the same frequencies (regardless of order). Otherwise 0.
fun all-cols-similarity(t :: Table, id) block:
  r = t.row-n(0)
  cols = get-unrestricted-cols(r).filter({(c): is-number(r[c])})
  when cols.length() == 0:
    raise(Err.message-exception("all-cols-similarity ignores certain columns (" + restricted-cols.join-str(", ") + "), but no other numeric columns were found"))
  end
  when not(t.column("ID").member(id)):
    raise(Err.message-exception("Could not find ID '" + id + "' in this table" ))
  end
  results = angle-similarity(t, id, cols)
  pull-seed-to-top(results, id)
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
  when not(t.column("ID").member(id)):
    raise(Err.message-exception("Could not find ID '" + id + "' in this table" ))
  end
  compare-to = t.filter({(r): r["ID"] == id}).row-n(0)
  fun compare-row(r): row-cosine-similarity(r, compare-to, cols) end
  results = t.build-column("cosine-similarity", compare-row).order-by("cosine-similarity", false)
  pull-seed-to-top(results, id)
end


# angle-similarity-lists: converts cosine similarity to degrees (0-90°).
# 0° means the DOCs are identical; 90° means completely dissimilar.
fun angle-similarity(t :: Table, id, cols :: List<String>) block:
  when not(t.column("ID").member(id)):
    raise(Err.message-exception("Could not find ID '" + id + "' in this table" ))
  end
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
  for fold(shadow grouped from table: interval, subtable end, s from splits) block:
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
          yes-lines = prefix-lines(to-lines(yes),     "├true─ ", "│   ")
          no-lines  = prefix-lines(to-lines(no), "└false─ ", "    ")
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
            {"predicted-" + to-string(pred); count-normalized(lbl, pred)}
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
    # Match on a word boundary: require the input followed by a space, so e.g.
    # "she" matches "she swallowed" but not "shell die" (she'll). The empty-input
    # case (used by choose-completion's back-off) still matches every n-gram.
    .filter({(r): (r["size"] == gram-size) and
        ((input == "") or string-starts-with(r["n-gram"], input + " "))})
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


fun choose-completion(model :: Table, input :: String, n :: Number) -> String:
  # An order-MAX-GRAM-SIZE model can only condition on the previous
  # MAX-GRAM-SIZE - 1 (= 4) tokens, so reduce any input to just its last
  # that-many tokens (the most recent context) before generating.
  fun last-tokens(str):
    toks = string-split-all(str, " ").filter(is-non-empty-string)
    toks.reverse().take(num-min(toks.length(), MAX-GRAM-SIZE - 1)).reverse().join-str(" ")
  end

  # Choose a single next word for `context`, backing off to a shorter context
  # (dropping the oldest word) when no n-gram matches the full context.
  fun choose-one(context):
    words = string-split-all(massage-string(context), " ")
      .filter(is-non-empty-string)
    last-word = if words.length() == 0: "" else: words.reverse().get(0) end

    choices = completions(model, context)
      .filter({(r): r["n-gram"] <> last-word})
    row-count = choices.length()

    if row-count == 0:
      if words.length() == 0:
        ""   # no context left to back off to
      else:
        choose-one(words.rest.join-str(" "))
      end
    else if row-count == 1:
      choices.row-n(0)["n-gram"]
    else:
      choices.row-n(random(row-count))["n-gram"]   # random(k) is in [0, k)
    end
  end

  # Choose n words in sequence, feeding each choice back in as context for the
  # next, and stopping early if we hit a dead end.
  fun choose-n(context, k):
    if k <= 0:
      empty
    else:
      word = choose-one(context)
      if word == "":
        empty
      else:
        link(word, choose-n(last-tokens(context + " " + word), k - 1))
      end
    end
  end

  choose-n(last-tokens(input), n).join-str(" ")
end

# append one generated word; choose-completion reduces the input to the last
# few tokens itself, so just pass the whole string through.
fun add-next-word(model :: Table, input :: String) -> String:
  input + " " + choose-completion(model, input, 1)
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
