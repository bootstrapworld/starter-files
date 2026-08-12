use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/refactor/libraries/", "core.arr")

_tri = triangle(20, "solid", "red")
_cir = circle(10, "solid", "yellow")
_sq = square(20, "solid", "blue")
_star = star(10, "solid", "pink")
_ellipse = ellipse(10, 20, "solid", "green")
_img-list = [list: _tri, _cir, _sq, _star, _ellipse]

examples "permute-wo-replace":
  permute-wo-replace([list: 1], 1) is [list: [list:1]]
  permute-wo-replace([list: 1, 2], 2) is [list: [list:1,2], [list:2,1]]
  permute-wo-replace([list: 1, 2, 3], 2) is [list:
    [list: 1, 2], [list: 1, 3],
    [list: 2, 1], [list: 2, 3],
    [list: 3, 1], [list: 3, 2]]
  permute-wo-replace([list: 1, 2, 3], 3) is [list:
    [list: 1, 2, 3], [list: 1, 3, 2],
    [list: 2, 1, 3], [list: 2, 3, 1],
    [list: 3, 1, 2], [list: 3, 2, 1]]
end

examples "permute-w-replace":
  permute-w-replace([list: 1], 1) is [list: [list:1]]
  permute-w-replace([list: 1, 2], 2) is [list: [list:1,1], [list:1,2], [list:2,1], [list:2,2]]
  permute-w-replace([list: 1, 2, 3], 2) is [list:
    [list: 1, 1], [list: 1, 2], [list: 1, 3],
    [list: 2, 1], [list: 2, 2], [list: 2, 3],
    [list: 3, 1], [list: 3, 2], [list: 3, 3]]
  permute-w-replace([list: 1, 2, 3], 3) is [list:
    [list: 1, 1, 1], [list: 1, 1, 2], [list: 1, 1, 3],
    [list: 1, 2, 1], [list: 1, 2, 2], [list: 1, 2, 3],
    [list: 1, 3, 1], [list: 1, 3, 2], [list: 1, 3, 3],
    [list: 2, 1, 1], [list: 2, 1, 2], [list: 2, 1, 3],
    [list: 2, 2, 1], [list: 2, 2, 2], [list: 2, 2, 3],
    [list: 2, 3, 1], [list: 2, 3, 2], [list: 2, 3, 3],
    [list: 3, 1, 1], [list: 3, 1, 2], [list: 3, 1, 3],
    [list: 3, 2, 1], [list: 3, 2, 2], [list: 3, 2, 3],
    [list: 3, 3, 1], [list: 3, 3, 2], [list: 3, 3, 3]]
end

examples "combine-wo-replace":
  combine-wo-replace([list:], 0) is [list: [list:]]
  combine-wo-replace([list:1], 1) is [list: [list: 1]]
  combine-wo-replace([list:1, 2], 1) is [list: [list:1], [list: 2]]
  combine-wo-replace([list:1, 2, 3], 2) is
  [list: [list:1,2], [list: 1,3], [list:2,3]]
end



# Consts for testing print-imgs
img1 = rectangle(340,180,"outline","black")
img2 = rectangle(180, 50,"outline","black")
img3 = rectangle(50,340,"outline","black")
img4 = rectangle(270,75,"outline","black")
img5 = rectangle(510,75,"outline","black")
img6 = rectangle(270,510,"outline","black")
#img7 = circle(50,"outline","black")
#img8 = triangle(100,"outline","black")

test-lst = [list: img1, img2, img3, img4, img5, img6,]
print-imgs(test-lst)

# Consts for testing union and intersection
small-lst = [list: -4, -3, -2, -1, 1, 2, 3, 4]
big-lst = [list: -400, -300, -200, 100, 200, 300, 400, 1000]
fun is-positive(x): x > 0 end
fun gt5(x): x > 5 end
fun lt1(x): x < 1 end
fun lt15(x): x < 15 end


"A simple inequality, with feedback for num-passing"
inequality(is-positive, big-lst)
"A union with overlap"
or-union(gt5, lt15, range-by(3, 24 + 1, 3))
"A union with NO overlap"
or-union(lt1, gt5, range-by(-21, 24 + 1, 6))
"An intersection with overlap"
and-intersection(gt5, lt15, range-by(3, 24 + 1, 3))
"An intersection with NO overlap"
and-intersection(lt1, gt5, range-by(-21, 24 + 1, 6))



#####################################################################
## Image testing
examples:
  image-entropy(square(10, "solid", "black")) is 0
  image-entropy(square(10, "solid", "white")) is 0
  image-luminance(square(10, "solid", "black")) is 0
  image-luminance(square(10, "solid", "white")) is 255
  lighter(square(10, "solid", "black"), square(10, "solid", "white")) is square(10, "solid", "white")
  darker(square(10, "solid", "black"), square(10, "solid", "white")) is square(10, "solid", "black")
  image-symmetry-vertical(triangle(20, "solid", "red")) is 1
  image-symmetry-horizontal(triangle(20, "solid", "red")) is-not-roughly 1
  image-symmetry-vertical(circle(20, "solid", "red")) is 1
  image-symmetry-horizontal(circle(20, "solid", "red")) is 1
end


########################################################################
## Trig functions


examples:
  sin(PI) is-roughly 0
  sin(2 * PI) is-roughly 0
  sin(PI / 2) is-roughly 1
  sin((3 * PI) / 2) is-roughly -1
  cos(PI / 3) is-roughly 0.5
  sin(PI / 6) is-roughly 0.5
end