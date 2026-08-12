use context starter2024

provide *

import image as I
import color as C
import either as Eth
import error as Err
import lists as L
import math as Math
import statistics as Stats
import tables as T
import string-dict as SD

include option

####################################################################
# foundations.arr
#
# Low-level primitives used throughout ds-tools.arr and ai-tools.arr:
# numeric/string formatting, the base shadows (translate, make-color,
# range, sin/cos/tan, image-url), small general utilities
# (maybe-get-value, TaggedFunction/guess-arity), pixel-level image
# analysis (image-entropy, dominant-rgb-colors, etc.), and basic text
# counting (num-words, num-sentences, num-syllables, sort-strings-ci).
#
# Split out of core.arr, which used to hold everything directly.
####################################################################


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
