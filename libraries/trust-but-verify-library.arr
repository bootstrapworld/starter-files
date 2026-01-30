use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "core.arr")
import csv as csv

provide *

animals-url = "https://docs.google.com/spreadsheets/d/1VeR2_bhpLvnRUZslmCAcSRKfZWs_5RNVujtZgEl6umA/export?format=csv"


###################### Load the data ##########################
_animals-table =
  load-table: name, species, sex, age, fixed, legs, pounds, weeks
  source: csv.csv-table-url(animals-url, {
    header-row: true,
    infer-content: true
  })
end


_verify = table: name, species, sex, age, fixed, legs, pounds, weeks end

is-fixed :: (animal :: Row) -> Boolean
# consume an animal and look up whether it's been fixed
fun is-fixed(animal):
  animal["fixed"]
end

is-male :: (animal :: Row) -> Boolean
# consumes an animal and computes whether it is male
fun is-male(animal):
  animal["sex"] == "male"
end

is-cat :: (animal :: Row) -> Boolean
# consumes an animal and looks up whether species is "cat"
fun is-cat(animal) :
  animal["species"] == "cat"
end

is-dog :: (animal :: Row) -> Boolean
# consumes an animal and looks up whether species is "dog"
fun is-dog(animal) :
  animal["species"] == "dog"
end

is-young :: (animal :: Row) -> Boolean
# consumes an animal and compute up whether the age is <2
fun is-young(animal) :
  animal["age"] < 2
end

nametag :: (animal :: Row) -> Image
# consumes an animal and computes an img of their name in red letters
fun nametag(animal) :
  text(animal["name"], 20, "red")
end

is-kitten :: (animal :: Row) -> Boolean
# consumes an animal and compute whether it's a cat, and <2 yrs old
fun is-kitten(animal) :
  (animal["species"] == "cat") and (animal["age"] < 2)
end

sentence :: (animal :: Row) -> String
# consumes an animal and compute a string: "<name> the <species>"
fun sentence(animal):
  animal["name"] + " the " + animal["species"]
end

is-old-dog :: (animal :: Row) -> Boolean
# consumes an animal and compute if it's a dog, and >9 yrs old
fun is-old-dog(animal):
  (animal["species"] == "dog") and (animal["age"] >= 9)
end

is-adult-dog :: (animal :: Row) -> Boolean
# consumes an animal and compute if it's a dog, and >5 yrs old
fun is-adult-dog(animal):
  (animal["species"] == "dog") and (animal["age"] >= 5)
end

fun fixed-catsA(t):
  t.filter(is-fixed).filter(is-kitten).order-by("age", true)
end


fun fixed-catsB(t):
  t.filter(is-fixed).filter(is-cat).order-by("age", true)
end


fun fixed-catsC(t):
  t.filter(is-cat).order-by("name", true)
end

fun old-dogs-nametagsA(t):
  t.filter(is-old-dog).build-column("label", nametag)
end

fun old-dogs-nametagsB(t):
  t.filter(is-adult-dog).build-column("label", nametag)
end


fun old-dogs-nametagsC(t):
  t.filter(is-old-dog).filter(is-fixed).build-column("label", nametag)
end

fun get-by-name(name):
  t = _animals-table.filter((lam(r): r["name"] == name end))
  if (t.length() == 0): raise("There is no animal named " + name)
  else: t.row-n(0)
  end
end

fun subset-from-names(names):
  names.map(get-by-name).foldl(lam(r, t): t.add-row(r) end, _verify)
end