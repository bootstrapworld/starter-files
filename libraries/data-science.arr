use context starter2024
include url("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/libraries/core.arr")

#for local debugging only
#include file("core.arr")

################################################################
# Bootstrap: DataScience
# Support files, as of Fall 2026

provide *

import lists as L
provide from L:
    * hiding(filter, sort, range),
  type *,
  data *
end


import math as Math
provide from Math:
    * hiding(sum),
  type *,
  data *
end

import statistics as Stats

var display-chart = lam(c): c.display() end

################# UTILITY FUNCTIONS ###########################

# override Pyret's native range (list) with range (stats)
shadow range = lam(t :: Table, col :: String) block:
  l = t.column(col).sort()
  num-to-string-digits(Math.max(l) - Math.min(l), 2)
end

# override Pyret's native translate with put-image
shadow translate = put-image

# re-export render-chart
shadow render-chart = render-chart

#################################################################################
# Table Functions

fun row-n(t :: Table, n :: Number) block:
  check-integrity(t, [list: ])
  t.row-n(n)
end


# if the column is a boolean, convert to a number and sort
shadow sort = lam(t :: Table, col :: String, asc :: Boolean):
  if ((t.all-rows().length() > 0) and is-boolean(t.row-n(0)[col])): t.build-column("tmp", lam(r):to-repr(r[col]) end).order-by("tmp", asc).drop("tmp")
  else: t.order-by(col, asc)
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
    raise("Cannot compute the mean, because the specified columns do not contain numeric data")
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
  chart = render-chart(series)
  img = display-chart(chart)
  title = make-title([list:"Distribution of", column-name])
  above(title, add-margin(img))
end

# no need to check integrity - all parent functions do it first
fun bar-chart-raw(t, ls, vs, column-name) block:
  labels = get-labels(t, ls)
  series = from-list.bar-chart(labels, ensure-numbers(t.column(vs)))
    .colors(t.column("_color"))
  chart = render-chart(series)
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
  image-pie-chart(t, col, lam(r): square(10, "solid", f(r)) end)
end


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

bar-chart :: (t :: Table, col :: String) -> Image
fun bar-chart(t, col) block:
  check-integrity(t, [list: col])
  summary = count(t, col)
  color-table = distinct-colors(summary, col)
  bar-chart-raw(color-table, col, "frequency", col)
end


color-bar-chart :: (t :: Table, col :: String, f :: (Row -> String)) -> Image
fun color-bar-chart(t, col, f) block:
  image-bar-chart(t, col, lam(r): square(10, "solid", f(r)) end)
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
  chart = render-chart(series).y-min(0)
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
  chart = render-chart(series).x-axis(col).y-axis(subcol)
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
  chart = render-chart(series)
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
  chart = render-chart(series)
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
  chart = render-chart(series)
  display-chart(chart)
end



## DOT PLOTS #############################################

simple-dot-plot :: (t :: Table, vals :: String) -> Image
fun simple-dot-plot(t, vals) block:
  check-integrity(t, [list: vals])
  vs = t.column(vals)
  series = if is-number(vs.get(0)):
    from-list.num-dot-chart(vs)
  else:
    raise(Err.message-exception("Cannot make a dot-plot, because the '" + vals + "' column does not contain quantitative data"))
  end
  chart = render-chart(series.point-size(8)).x-axis(vals).y-axis("frequency")
  img = display-chart(chart)
  title = make-title([list:"Dot Plot of", vals])
  above(title, add-margin(img))
end

dot-plot :: (t :: Table, labels :: String, vals :: String) -> Image
fun dot-plot(t, labels, vals) block:
  check-integrity(t, [list: labels, vals])
  ls = t.column(labels).map(to-repr)
  series = if is-number(t.column(vals).get(0)):
    from-list.labeled-num-dot-chart(ls, t.column(vals)).point-size(8)
  else:
    raise(Err.message-exception("Cannot make a dot-plot, because the '" + vals + "' column does not contain quantitative data"))
  end
  chart = render-chart(series)
    .x-axis(vals)
    .y-axis("frequency")
  img = display-chart(chart)
  title = make-title([list:"Dot Plot of", vals])
  above(title, add-margin(img))
end


fun image-dot-plot(t, vals, f :: (Row -> Image)) block:
  check-integrity(t, [list: vals])
  images = t.all-rows().map(f)
  max-height = images.map(image-height).foldl(num-max, 0)
  series = if is-number(t.column(vals).get(0)):
    from-list.image-num-dot-chart(images, t.column(vals)).point-size(max-height)
  else:
    from-list.dot-chart(t.column(vals))
  end
  chart = render-chart(series).x-axis(vals).y-axis("frequency")
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
    chart = render-chart(from-list.histogram(ensure-numbers(t.column(vals))).bin-width(bin-width))
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
    chart = render-chart(from-list.labeled-histogram(
        t.column(labels).map(to-repr),
        ensure-numbers(t.column(vals))).bin-width(bin-width))
      .x-axis(vals)
      .y-axis("frequency")
    img = display-chart(chart)
    title = make-title([list:"Distribution of", vals])
    above(title, add-margin(img))
  end
end

color-histogram :: (t :: Table, vals :: String, bin-width :: Number, f :: (Row -> String)) -> Image
fun color-histogram(t, vals, bin-width, f) block:
  image-histogram(t, vals, bin-width, lam(r): square(10, "solid", f(r)) end)
end

image-histogram :: (t :: Table, vals :: String, bin-width :: Number, f :: (Row -> Image)) -> Image
fun image-histogram(t, vals, bin-width, f) block:
  check-integrity(t, [list: vals])
  images = t.all-rows().map(f)
  if not(is-number(t.column(vals).get(0))):
    raise(Err.message-exception("Cannot make a histogram, because the '" + vals + "' column does not contain quantitative data"))
  else:
    chart = render-chart(from-list.image-histogram(images, ensure-numbers(t.column(vals))).bin-width(bin-width))
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
    chart = render-chart(from-list.histogram(ensure-numbers(t.column(vals))).bin-width(bin-width))
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
  if not(is-number(l.get(0))):
    raise(Err.message-exception("Cannot make a box plot, because the 'values' column does not contain numeric data"))
  else if (low > high):
    raise(Err.message-exception("Min value must be lower than Max value"))
  else:
    series = from-list.labeled-box-plot([list: vs], [list: l])
      .horizontal(horizontal).show-outliers(showOutliers)
      .color(make-color(0,0,100,1))
    chart = render-chart(series)
      .title(get-5-num-summary(t, vs))
      .min(low).max(high)
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
  chart = render-chart(from-list.labeled-line-plot(ls, sorted.column(xs), sorted.column(ys)))
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
    chart = render-chart(from-list.labeled-scatter-plot(ls, ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys))))
      .x-axis(xs)
      .y-axis(ys)
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
    chart = render-chart(from-list.scatter-plot(ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys))))
      .x-axis(xs)
      .y-axis(ys)
    img = display-chart(chart)
    title = make-title([list:"", ys, "vs.", xs])
    above(title, add-margin(img))
  end
end

color-scatter-plot :: (t :: Table, xs :: String, ys :: String, f :: (Row -> Image)) -> Image
fun color-scatter-plot(t, xs, ys, f) block:
  image-scatter-plot(t, xs, ys, lam(r): circle(5, "solid", f(r)) end)
end

image-scatter-plot :: (t :: Table, xs :: String, ys :: String, f :: (Row -> Image)) -> Image
fun image-scatter-plot(t, xs, ys, f) block:
  check-integrity(t, [list: xs, ys])
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make an image scatter plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    images = t.all-rows().map(f)
    chart = render-chart(from-list.image-scatter-plot(images, ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys))))
      .x-axis(xs)
      .y-axis(ys)
    img = display-chart(chart)
  title = make-title([list:"", ys, "vs.", xs])
    above(title, add-margin(img))
  end
end


multiple-regression :: (
  t :: Table,
  explanations :: List<String>,
  response :: String) ->
(List<Number> -> Number)
fun multiple-regression(t, explanations, response):
  # convert the table to a list of rows, then each row to a list of values
  if explanations.length() > t.length():
      raise(Err.message-exception("This data set contains too few data samples and too many independent variables to produce a unique regression.  If all the independent variables are needed, you'll need to collect more data samples; otherwise, try removing ones that aren't relevant"))
      else:
      explanation-lists = t.all-rows().map(
        lam(r): explanations.map(lam(exp): r[exp] end) end)
      response-list = t.column(response)
      Stats.multiple-regression(explanation-lists, response-list)
  end
  #"The Statistics module does not currently provide a multiple-regression function"
end


fun make-lr-title(fn, r-sqr-num, s-num) :
  r-num = (if  (fn(1) - fn(0)) < 0: -1 else: 1 end) * num-sqrt(r-sqr-num)
  alpha  = fn(2) - fn(1)
  alpha-str = easy-num-repr(fn(2) - fn(1), 8)
  beta-str =  easy-num-repr(fn(0), 8)
  r-str = easy-num-repr(r-num, 6)
  r-sqr-str = easy-num-repr(r-sqr-num, 6)
  S-str     = easy-num-repr(s-num, 9)
  "y=" + alpha-str + "x + "  + beta-str + "  r: " + r-str + "  R²: " + r-sqr-str + "  S: " + S-str
end

lr-plot :: (t :: Table, ls :: String, xs :: String, ys :: String) -> Image
fun lr-plot(t, ls, xs, ys) block:
  check-integrity(t, [list: ls, xs, ys])
  labels = get-labels(t, ls)
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make an lr-plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    scatter = from-list.labeled-scatter-plot(labels, ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys)))
      .legend("Data")
    fn = Stats.linear-regression(t.column(xs), t.column(ys))
    fn-plot = from-list.function-plot(fn)
      .legend("Model")
    s-num = S(t, xs, ys, fn)
    r-sqr-num = Stats.r-squared(t.column(xs), t.column(ys), fn)
    chart = render-charts([list: scatter, fn-plot])
      .title(make-lr-title(fn, r-sqr-num, s-num))
      .x-axis(xs)
      .y-axis(ys)
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
    fn = Stats.linear-regression(t.column(xs), t.column(ys))
    fn-plot = from-list.function-plot(fn)
    s-num = S(t, xs, ys, fn)
    r-sqr-num = Stats.r-squared(t.column(xs), t.column(ys), fn)
    chart = render-charts([list: scatter, fn-plot])
      .title(make-lr-title(fn, r-sqr-num, s-num))
      .x-axis(xs)
      .y-axis(ys)
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
    scatter = from-list.image-scatter-plot(
      images,
      ensure-numbers(t.column(xs)),
      ensure-numbers(t.column(ys)))
      .legend("Data")
    fn = Stats.linear-regression(t.column(xs), t.column(ys))
    fn-plot = from-list.function-plot(fn)
      .legend("Model")
    s-num = S(t, xs, ys, fn)
    r-sqr-num = Stats.r-squared(t.column(xs), t.column(ys), fn)
    chart = render-charts([list: scatter, fn-plot])
      .title(make-lr-title(fn, r-sqr-num, s-num))
      .x-axis(xs)
      .y-axis(ys)
    img = display-chart(chart)
    title = make-title([list:"", ys, "vs.", xs])
    above(title, add-margin(img))
  end
end

residuals :: (t :: Table, xs :: String, ys :: String, fn :: (Number -> Number)) -> List<Number>
fun residuals(t, xs, ys, fn) block:
  check-integrity(t, [list: xs, ys])
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot calculate residuals, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    map2(
      lam(y, prediction): y - prediction end,
      t.column(ys),
      map(fn, t.column(xs)))
  end
end

S :: (t :: Table, xs :: String, ys :: String, fn :: (Number -> Number)) -> Number
fun S(t, xs, ys, fn) block:
  check-integrity(t, [list: xs, ys])
  datapoints = t.column(xs).length()
  if (datapoints <= 2):
    raise(Err.message-exception("Cannot calculate S for this model and function, because a model with two parameters requires a table with at least 3 rows"))
  else:
    residuals-sqr = residuals(t,xs,ys,fn).map(num-sqr)
    degrees-of-freedom = datapoints - 2
    num-sqrt(Math.sum(residuals-sqr) / degrees-of-freedom)
  end
end

fit-model :: (t :: Table, ls :: String, xs :: String, ys :: String, fn :: (Number -> Number)) -> Image
fun fit-model(t, ls, xs, ys, fn) block:
  check-integrity(t, [list: ls, xs, ys])
  labels = get-labels(t, ls)

  # the line below calls S, which does our error-checking
  S-value     = S(t, xs, ys, fn)
  R-sqr-value = Stats.r-squared(t.column(xs), t.column(ys), fn)
  S-str       = easy-num-repr(S-value, 10)
  #r-str       = if (R-sqr-value > 0): easy-num-repr(num-sqrt(R-sqr-value)) else: "N/A" end
  r-sqr-str   = easy-num-repr(R-sqr-value, 10)

  scatter = from-list.labeled-scatter-plot(
    labels,
    ensure-numbers(t.column(xs)),
    ensure-numbers(t.column(ys)))
    .legend("Data")
    .point-size(5)
  fn-plot = from-list.function-plot(fn)
    .legend("Model")
  intervals = from-list.interval-chart(
    t.column(xs),
    t.column(ys),
    residuals(t, xs, ys, fn))
    .point-size(1)
    .pointer-color("green")
    .lineWidth(10)
    .color("black")
    .style("sticks")
    .legend("Residuals")
  title-str = "S: " + S-str + "   R²: " + r-sqr-str
  chart = render-charts([list: fn-plot, scatter, intervals])
    .title(title-str)
    .x-axis(xs)
    .y-axis(ys)
  img = display-chart(chart)
  title = make-title([list:"", ys, "vs.", xs])
  above(title, add-margin(img))
end


###########################################################################
# GRAPHING AND TABLE FUNCTIONS

function-plot :: (f :: (Number -> Number)) -> Image
fun function-plot(f):
  chart = render-chart(from-list.function-plot(f))
    .x-axis("x")
    .y-axis("y")
  display-chart(chart)
end

def-to-table :: (start :: Number, stop :: Number, f :: (Number -> Number)) -> Table
# Consumes x1, x2, step-size, and the name of a function, and produces an x/y table
fun def-to-table(start, stop, f):
  xs = L.range-by(start, stop + 1, ((stop + 1) - start) / 50)
  ys = xs.map(f)
  [T.table-from-columns: {"x"; xs}, {"y"; ys}]
end

def-to-graph :: (f :: (Number -> Number)) -> Image
# Same as make-table, but makes a line-plot of the resulting table
fun def-to-graph(f) block:
  chart = render-chart(from-list.function-plot(f))
    .x-axis("x")
    .y-axis("y")
    .x-min(-10)
    .x-max(10)
    .y-min(-10)
    .y-max(10)
  display-chart(chart)
end

table-to-graph :: (t :: Table) -> Image
# Consumes a table, and makes a line-plot from the first 2 columns
fun table-to-graph(t) block:
  check-integrity(t, [list: "x", "y"])
  cols = t.column-names()
  if (cols.length() < 2): raise(Err.message-exception("The table must have at least two columns"))
  else:
    xs = t.column(cols.get(0))
    ys = t.column(cols.get(1))
    chart = render-chart(from-list.line-plot(xs, ys))
      .x-axis(cols.get(0))
      .y-axis(cols.get(1))
      .x-min(num-round(Math.min(xs)))
      .x-max(num-round(Math.max(xs)))
    if num-round(Math.min(ys)) == num-round(Math.max(ys)):
      display-chart(chart)
    else:
      display-chart(chart
        .y-min(num-round(Math.min(ys)))
        .y-max(num-round(Math.max(ys))))
    end
  end
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


#####################################################################
#####################################################################
############################### TESTING #############################
#####################################################################
#####################################################################

#|
# Load your spreadsheet and define your table
shelter-sheet = load-spreadsheet(
"https://docs.google.com/spreadsheets/d/1VeR2_bhpLvnRUZslmCAcSRKfZWs_5RNVujtZgEl6umA/")

# load the 'animals' sheet as a table
animals-table =
  load-table: name, species, sex, age, fixed, legs, pounds, weeks
  source: shelter-sheet.sheet-by-name("pets", true)
end

pie-chart(animals-table, "species")
bar-chart(animals-table, "species")
image-pie-chart(animals-table, "species", lam(x): circle(10,"solid","red") end)
image-bar-chart(animals-table, "species", lam(x): circle(10,"solid","red") end)
dot-plot(animals-table, "name", "pounds")
scatter-plot(animals-table, "name", "weeks", "pounds")
histogram(animals-table, "name", "pounds", 7)
box-plot(animals-table, "weeks")

#split-and-reduce(animals-table, "species", "pounds", sum)
#group-and-subgroup(animals-table, "species", "sex")
#group(animals-table, "sex")

|#