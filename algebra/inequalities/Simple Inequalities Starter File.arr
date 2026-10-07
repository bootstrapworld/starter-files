use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/main/algebra/inequalities", "../../libraries/core.arr")

# Read the example code below carefully!
# Then click "Run" to see what happens.

# 1) DEFINE INEQUALITY FUNCTIONS

fun less-than-zero(x): x < 0 end
# less-than-zero : Number -> Boolean
# An inequality expressed as a function that tests if x < 0

fun at-least-zero(x): x >= 0 end
# at-least-zeri : Number -> Boolean
# An inequality expressed as a function that tests if x is greater than or equal to zero.


# 2) DEFINE A LIST OF 8 NUMBERS TO TEST...

listA = [list: -4, -3, -2.5, -1, 0, 1, 2, 6]

# Any testing list should include the number from the inequality
# The inequality should produce TRUE for four numbers
# The inequality should produce FALSE for four numbers

listB = [list: -5, -3, -1.5, -1, 0, 1, 3, 5]

# 🌟Challenge yourself to DEFINE your list using 8 interesting numbers! 
# (negatives, fractions, decimals, etc). For example: 
# listZ = [list: -4.1, -3, -2, -1/2, 0, num-sqrt(2), 3.14, 4]


# 3) PLOT YOUR INEQUALITY WITH YOUR LIST OF TEST POINTS ON A NUMBER LINE

"Plot less-than-zero as an inequality"
inequality(less-than-zero, listA)

"Plot at-least-zero as an inequality"
inequality(at-least-zero, listB)

# Numbers that are part of the solution will appear as green dots with a T
# Numbers that are *not* part of the solution will appear as red dots with an F
# All other numbers that are part of the solution will be shaded

#4) Repeat the steps above for each inequality on the assignment.
