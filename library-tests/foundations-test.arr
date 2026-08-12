use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/refactor/", "libraries/foundations.arr")

import lists as L

examples "string-trim":
  string-trim("  hello  ")   is "hello"
  string-trim("\t hi \n")    is "hi"
  string-trim("no-spaces")   is "no-spaces"
  string-trim("   ")         is ""
  string-trim("")            is ""
end

examples "sort-strings-ci":
  sort-strings-ci([L.list: "Banana", "apple", "Cherry"]) is [L.list: "apple", "Banana", "Cherry"]
  sort-strings-ci([L.list: "Z", "a", "M"])               is [L.list: "a", "M", "Z"]
end


examples "round-digits":
  round-digits(1.24, 1) is 1.2
  round-digits(num-sqrt(2), 3) is 1.414
end

examples "log functions":
  log-base(3, 9) is 2
  log-base(3, 1/9) is -2
  num-log(9) / num-log(3) satisfies num-is-roughnum
  log-base(4, 32) is 2.5
end


examples "easy-num-repr":
  easy-num-repr(0.0001234, 6) is "0.0001"
  easy-num-repr(2343.234, 6) is "2343.2"
  easy-num-repr(0.000000001234, 6) is "1.2e-9"
  easy-num-repr(2343243432.234, 6) is "2.34e9"
  easy-num-repr(~0.082805, 9) is "~0.082805"
  easy-num-repr(0.0999999, 5) is "0.100"
  easy-num-repr(0.9999999, 5) is "1"
  easy-num-repr(~-125137.47385839373, 8) is "~-125137"
  easy-num-repr(~-125137.67385839373, 8) is "~-125138"
  easy-num-repr(9999.99, 3) raises "Could not fit"
end
