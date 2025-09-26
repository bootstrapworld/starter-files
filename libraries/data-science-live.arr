use context starter2024
#include url("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/libraries/core.arr")

#for local debugging only
include file("core.arr")

################################################################
# Bootstrap: DataScience Live Survey
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
    | right(v) => raise(Err.message-exception("The chart you are making can only display 1 image for the all the rows represented in each '" + col + "', so your drawing function must only use the '" + col + "' column"))
  end
end

fun pie-chart-raw(t, ls, vs, column-name) block:
  labels = get-labels(t, ls)
  series = from-list.pie-chart(labels, ensure-numbers(t.column(vs)))
    .colors(t.column("_color"))
  img = render-chart(series).get-image()
  title = make-title([list:"Distribution of", column-name])
  above(title, img)
end

# no need to check integrity - all parent functions do it first
fun bar-chart-raw(t, ls, vs, column-name) block:
  labels = get-labels(t, ls)
  series = from-list.bar-chart(labels, ensure-numbers(t.column(vs)))
    .colors(t.column("_color"))
  img = render-chart(series)
    .x-axis(column-name)
    .y-axis(vs)
    .y-min(0)
    .get-image()
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

image-pie-chart :: (t :: Table, col :: String, f :: (Row -> Image)) -> Image
fun image-pie-chart(t, col, f) block:
  check-integrity(t, [list: col])
  summary = count(t, col)
  images = make-images-from-grouped-rows(summary, col, f)
  series = from-list.image-pie-chart(
    images,
    get-labels(summary, col), 
    ensure-numbers(summary.column("frequency")))
  img = render-chart(series)
    .get-image()
  title = make-title([list:"Distribution of", col])
  above(title, img)
end

bar-chart :: (t :: Table, col :: String) -> Image
fun bar-chart(t, col) block:
  check-integrity(t, [list: col])
  summary = count(t, col)
  color-table = distinct-colors(summary, col)
  bar-chart-raw(color-table, col, "frequency", col)
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
  img = render-chart(series)
    .y-min(0)
    .get-image()
  title = make-title([list:"Distribution of", col])
  above(title, img)
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
  img = render-chart(series)
    .x-axis(col)
    .y-axis(subcol)
    .get-image()
  title = make-title([list:"Distribution of", subcol, "by", col])
  above(title, img)
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
  render-chart(series).get-image()
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
  img = render-chart(series)
    .x-axis(col + " ⋲ " + subcol)
    .y-axis("frequency")
    .get-image()
  title = make-title([list:"Distribution of", subcol, "by", col])
  above(title, img)
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
  render-chart(series).get-image()
end



## DOT PLOTS #############################################

simple-dot-plot :: (t :: Table, vals :: String) -> Image
fun simple-dot-plot(t, vals) block:
  check-integrity(t, [list: vals])
  vs = t.column(vals)
  series = if is-number(vs.get(0)):
    from-list.num-dot-chart()
  else: 
    from-list.dot-chart(vs)
  end
  img = render-chart(series.point-size(8))
    .x-axis(vals)
    .y-axis("frequency")
    .get-image()
  title = make-title([list:"Dot Plot of", vals])
  above(title, img)
end

dot-plot :: (t :: Table, labels :: String, vals :: String) -> Image
fun dot-plot(t, labels, vals) block:
  check-integrity(t, [list: labels, vals])
  ls = t.column(labels).map(to-repr)
  series = if is-number(t.column(vals).get(0)):
    from-list.labeled-num-dot-chart(ls, t.column(vals)).point-size(8)
  else: 
    from-list.dot-chart(t.column(vals))
  end
  img = render-chart(series)
    .x-axis(vals)
    .y-axis("frequency")
    .get-image()
  title = make-title([list:"Dot Plot of", vals])
  above(title, img)
end



## HISTOGRAMS #############################################
simple-histogram :: (t :: Table, vals :: String, bin-width :: Number) -> Image
fun simple-histogram(t, vals, bin-width) block:
  doc: "wrap histogram so that the bin-width is set"
  check-integrity(t, [list: vals])
  if not(is-number(t.column(vals).get(0))):
    raise(Err.message-exception("Cannot make a histogram, because the '" + vals + "' column does not contain quantitative data"))
  else:
    img = render-chart(from-list.histogram(ensure-numbers(t.column(vals))).bin-width(bin-width))
      .x-axis(vals)
      .y-axis("frequency")
      .get-image()
    title = make-title([list:"Distribution of", vals])
    above(title, img)
  end
end

histogram :: (t :: Table, labels :: String, vals :: String, bin-width :: Number) -> Image
fun histogram(t, labels, vals, bin-width) block:
  doc: "wrap histogram so that the bin-width is set"
  check-integrity(t, [list: labels, vals])
  if not(is-number(t.column(vals).get(0))):
    raise(Err.message-exception("Cannot make a histogram, because the '" + vals + "' column does not contain quantitative data"))
  else:
    img = render-chart(from-list.labeled-histogram(
        t.column(labels).map(to-repr),
        ensure-numbers(t.column(vals))).bin-width(bin-width))
      .x-axis(vals)
      .y-axis("frequency")
      .get-image()
    title = make-title([list:"Distribution of", vals])
    above(title, img)
  end
end

image-histogram :: (t :: Table, vals :: String, bin-width :: Number, f :: (Row -> Image)) -> Image
fun image-histogram(t, vals, bin-width, f) block:
  check-integrity(t, [list: vals])
  images = t.all-rows().map(f)
  if not(is-number(t.column(vals).get(0))):
    raise(Err.message-exception("Cannot make a histogram, because the '" + vals + "' column does not contain quantitative data"))
  else:
    img = render-chart(from-list.image-histogram(images, ensure-numbers(t.column(vals))).bin-width(bin-width))
      .x-axis(vals)
      .y-axis("frequency")
      .get-image()
    title = make-title([list:"Distribution of", vals])
    above(title, img)
  end
end

scaled-histogram :: (t :: Table, vals :: String, bin-width :: Number, low :: Number, high :: Number) -> Image
fun scaled-histogram(t, vals, bin-width, low, high) block:
  doc: "wrap histogram so that the bin-width is set"
  check-integrity(t, [list: vals])
  if not(is-number(t.column(vals).get(0))):
    raise(Err.message-exception("Cannot make a histogram, because the '" + vals + "' column does not contain quantitative data"))
  else:
    img = render-chart(from-list.histogram(ensure-numbers(t.column(vals))).bin-width(bin-width))
      .x-axis(vals)
      .y-axis("frequency")
      .min(low).max(high)
      .get-image()
    title = make-title([list:"Distribution of", vals])
    above(title, img)
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
    img = render-chart(series)
      .title(get-5-num-summary(t, vs))
      .min(low).max(high)
      .get-image()
    title = make-title([list:"Distribution of", vs])
    above(title, img)
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
  img = render-chart(from-list.labeled-line-plot(ls, sorted.column(xs), sorted.column(ys)))
    .x-axis(xs)
    .y-axis(ys)
    .get-image()
  title = make-title([list:"", ys, "vs.", xs])
  above(title, img)
end


## LR AND SCATTER PLOTS #############################################
scatter-plot :: (t :: Table, labels :: String, xs :: String, ys :: String) -> Image
fun scatter-plot(t, labels, xs, ys) block:
  check-integrity(t, [list: labels, xs, ys])
  ls = get-labels(t, labels)
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make a scatter plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    img = render-chart(from-list.labeled-scatter-plot(ls, ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys))))
      .x-axis(xs)
      .y-axis(ys)
      .get-image()
  title = make-title([list:"", ys, "vs.", xs])
  above(title, img)
  end
end

simple-scatter-plot :: (t :: Table, xs :: String, ys :: String) -> Image
fun simple-scatter-plot(t, xs, ys) block:
  check-integrity(t, [list: xs, ys])
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make a scatter plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    img = render-chart(from-list.scatter-plot(ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys))))
      .x-axis(xs)
      .y-axis(ys)
      .get-image()
    title = make-title([list:"", ys, "vs.", xs])
    above(title, img)
  end
end

image-scatter-plot :: (t :: Table, xs :: String, ys :: String, f :: (Row -> Image)) -> Image
fun image-scatter-plot(t, xs, ys, f) block:
  check-integrity(t, [list: xs, ys])
  if not(is-number(t.column(xs).get(0)) and is-number(t.column(ys).get(0))):
    raise(Err.message-exception("Cannot make an image scatter plot, because the 'xs' and 'ys' columns must both contain numeric data"))
  else:
    images = t.all-rows().map(f)
    img = render-chart(from-list.image-scatter-plot(images, ensure-numbers(t.column(xs)), ensure-numbers(t.column(ys))))
      .x-axis(xs)
      .y-axis(ys)
      .get-image()
  title = make-title([list:"", ys, "vs.", xs])
  above(title, img)
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
  alpha-str = easy-num-repr(fn(2) - fn(1), 8)
  beta-str =  easy-num-repr(fn(0), 8)
  r-str = easy-num-repr(r-num, 6)
  r-sqr-str = easy-num-repr(r-sqr-num, 6)
  S-str     = easy-num-repr(s-num, 9)
  "y=" + alpha-str + "x +" + " " + beta-str + "   r: " + r-str + "  r²: " + r-sqr-str + "  S: " + S-str
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
    img = render-charts([list: scatter, fn-plot])
      .title(make-lr-title(fn, r-sqr-num, s-num))
      .x-axis(xs)
      .y-axis(ys)
      .get-image()
    title = make-title([list:"", ys, "vs.", xs])
    above(title, img)
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
    img = render-charts([list: scatter, fn-plot])
      .title(make-lr-title(fn, r-sqr-num, s-num))
      .x-axis(xs)
      .y-axis(ys)
      .get-image()    
    title = make-title([list:"", ys, "vs.", xs])
    above(title, img)
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
    img = render-charts([list: scatter, fn-plot])
      .title(make-lr-title(fn, r-sqr-num, s-num))
      .x-axis(xs)
      .y-axis(ys)
      .get-image()       
    title = make-title([list:"", ys, "vs.", xs])
    above(title, img)
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
  title-str = "S: " + S-str + "   R-sqr: " + r-sqr-str
  img = render-charts([list: fn-plot, scatter, intervals])
    .title(title-str)
    .x-axis(xs)
    .y-axis(ys)
    .get-image()
  title = make-title([list:"", ys, "vs.", xs])
  above(title, img)
end


