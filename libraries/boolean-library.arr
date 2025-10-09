use context starter2024
provide *

is-continent :: String -> Boolean
fun is-continent(x) block: 
  test = string-to-lower(x)
  ask:
    | string-equal(test, "europe") then: true
    | string-equal(test, "south america") then: true
    | string-equal(test, "asia") then: true
    | string-equal(test, "north america") then: true
    | string-equal(test, "antarctica") then:  true
    | string-equal(test, "australia") then: true
    | string-equal(test, "africa") then: true
    | otherwise: false
  end
end

is-primary-color :: String -> Boolean
fun is-primary-color(x): 
  ask:
    | string-equal(x, "blue") then: true
    | string-equal(x, "red") then: true
    | string-equal(x, "yellow") then: true
    | otherwise: false
  end
end

is-less-than-one :: Number -> Boolean
fun is-less-than-one(n):
  n < 1
end

is-even :: NumInteger -> Boolean
fun is-even(n):
    num-modulo(n, 2) == 0
end
is-odd :: NumInteger -> Boolean
fun is-odd(n):
  not(is-even(n))
end