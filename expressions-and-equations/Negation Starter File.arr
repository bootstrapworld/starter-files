use context url-file(https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/expressions-and-equations/", "../libraries/core.arr")

####### Section 1: Variable Definitions ###############

m = 6


####### Section 2:  Examples ##########################

examples: 
  
  negate(m) == abs(m)                 is true
  
  negate(m) == negate(abs(m))         is true
  
  negate(m) == abs(negate(m))         is true
  
  abs(negate(m)) == negate(negate(m)) is true
   
  abs(negate(m)) == negate(abs(m))    is true
  
end


