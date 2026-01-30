use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/algebra/inequalities", "../../libraries/core.arr")

# We are going to be exploring compound inequalities today. 
# Read the example code below carefully!
# And click run to see what happens.

# WE'VE DEFINED 2 BOOLEAN-PRODUCING FUNCTIONS (You will define more later)
fun B(x): x > 5 end
fun C(x): x <= 15 end

# WE'VE DEFINED "points" TO BE A LIST OF 8 VALUES TO PLOT AND TEST 
points = [list: -5, -2.1, 0, 5, 10.2, 25/2, 15, 20]

# NEXT WE'LL GRAPH EACH FUNCTION ON A NUMBER LINE AS SEPARATE INEQUALITIES AND TEST THE 8 VALUES IN EACH
inequality(B, points)
inequality(C, points)

# Numbers that are part of the solution will appear as green dots
# Numbers that are *not* part of the solution will appear as red dots
# All other numbers will be shaded if they are part of the solution

# AND THEN WE'LL CONSIDER THE INEQUALITIES TOGETHER

# TEST THEIR INTERSECTION (Which inputs make BOTH of the expressions TRUE?)
# and-intersection:: Function, Function, List -> Image
and-intersection( B, C, points )

# TEST THEIR UNION (Which inputs make AT LEAST ONE of the expressions TRUE?)
# or-union:: Function, Function, List -> Image
or-union( B, C, points )