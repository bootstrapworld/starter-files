use context file("../libraries/core.arr")

examples:
  
  expt(5, 2) == (2 * (2 * (2 * (2 * 2))))       is true
  expt(4, 6) == (4 * (4 * (4 * (4 * (4 * 4))))) is true
  expt(2, 3) == (3 * 3)                         is true
  expt(8, 3) == (8 * (8 * 8))                   is true
  expt(3, 5) == (3 + (3 + (3 + (3 + 3))))       is true
  expt(1, 4) == (1 * (1 * (1 * 1)))             is true
    
end

