use context file("../../libraries/core.arr")

# Images for "Luigi's Italian Safari"
ravioli = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/algebra/combinatorics/ravioli.png")
pizza = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/algebra/combinatorics/pizza.png")
ziti = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/algebra/combinatorics/ziti.png")
chicken = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/algebra/combinatorics/chicken.png")
lasagna = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/algebra/combinatorics/lasagna.png")
soup = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/algebra/combinatorics/soup.png")

# Luigi's 6-item menu
menu = [list: lasagna, pizza, chicken, ravioli, soup, ziti]
# The same menu, but with letters instead of pictures
letters = [list: "L", "P", "C", "R", "S", "Z"]

# Luigi's 4-item menu
small-menu = [list: lasagna, pizza, chicken, ravioli]
# The same menu, but with letters instead of pictures
small-letters = [list: "L", "P", "C", "R"]


###########################################################
#                       PERMUTATIONS
###########################################################
# 1) Show all possible permutations for a 1-course
# meal chosen from the full menu, by typing
# permute-w-replace(menu, 1) to see pictures, or
# permute-w-replace(letters, 1) to see letters

# NOTE: clicking on the first 'list:' in the output will
# show each list item on a separate, numbered line!!

# 1a. How many permutations are there for a 2-course meal?
# 1b. How many permutations are there for a 3-course meal?
# 1c. How many permutations are there for a 4-course meal?

###########################################################
# 2) Define a function num-permute-w-replace, which
# consumes the number of items and the number of choices
# and produces the number of possible permutations (with
# replacement). Use your answers from 1a-1c as examples!





###########################################################
# 3) Show all possible *NON-REPEATING* permutations 
# for a 1-course meal chosen from that menu, by 
# typing permute-wo-replace(small-menu, 1) to see pictures, or
# permute-wo-replace(small-letters, 1) to see letters

# 3a. How many permutations are there for a 2-course meal?
# 3b. How many permutations are there for a 3-course meal?
# 3c. How many permutations are there for a 4-course meal?
# 3d. How many permutations are there for a 2-course meal,
# using the original menu?
# 3e. How many permutations are there for a 3-course meal,
# using the original menu?
# 3f. How many permutations are there for a 4-course meal,
# using the original menu?

###########################################################
# 4) Define a function num-permute-wo-replace, which
# consumes the number of items and the number of choices
# and produces the number of possible permutations (without
# replacement). Use your answers from 3a-3c as examples!








###########################################################
#                       COMBINATIONS
###########################################################
# 5) Show all possible *NON-REPEATING* combinations 
# for a 1-course meal chosen from the menu, by 
# typing combine-wo-replace(menu, 1)

# 5a. How many combinations are there for a 2-course meal?
# 5b. How many combinations are there for a 3-course meal?
# 5c. How many combinations are there for a 4-course meal?

###########################################################
# 6) Define a function num-combine-wo-replace, which
# consumes the number of items and the number of choices
# and produces the number of possible combinations (without
# replacement). Use your answers from 5a-5c as examples!