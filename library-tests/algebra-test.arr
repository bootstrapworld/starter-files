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
## Note: image-analysis and trig-function tests moved to
## foundations-test.arr -- those functions are defined in
## foundations.arr, not algebra-tools.arr, and belong there.

examples "factorial":
  factorial(0) is 1
  factorial(1) is 1
  factorial(5) is 120
end

examples "whats-missing":
  whats-missing([list: 1, 2, 3], [list: 1, 2]) is [list: 3]
  whats-missing([list: 1, 2], [list: 1, 2]) is "You got them all!"
end

examples "render-list":
  render-list([list: [list: "a", "b"], [list: "c", "d"]]) satisfies is-image
  render-list([list: [list: 1, 2], [list: 3, 4]]) satisfies is-image
end

unspoken-sq = square(10, "solid", "red")
examples "unspoken-img":
  image-width(unspoken-img(unspoken-sq)) is image-width(unspoken-sq)
  image-height(unspoken-img(unspoken-sq)) is image-height(unspoken-sq)
end