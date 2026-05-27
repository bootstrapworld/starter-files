use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")
badger = "The American badger is a North American badger similar in appearance to the European badger, although not closely related. It is found in the western, central, and northeastern United States, northern Mexico, and south-central Canada to certain areas of southwestern British Columbia. The American badger's habitat is typified by open grasslands with available prey (such as mice, squirrels, and groundhogs)."

blue-whale = "The blue whale is a marine mammal and a baleen whale. Reaching a maximum confirmed length of 29.9 m and weighing up to 199 tons, it is the largest animal known ever to have existed. The blue whale's long and slender body can be of various shades of greyish-blue on its upper surface and somewhat lighter underneath."

chimpanzee = "The chimpanzee lives in groups that range in size from 15 to 150 members, although individuals travel and forage in much smaller groups during the day. The species lives in a strict male-dominated hierarchy, where disputes are generally settled without the need for violence. Nearly all chimpanzee populations have been recorded using tools, modifying sticks, rocks, grass and leaves and using them for hunting and acquiring honey, termites, ants, nuts and water."

elephant = "The elephant has been a contributor to Thai society and its icon for many centuries. The elephant has had a considerable impact on Thai culture. The Thai elephant is the official national animal of Thailand. The elephant found in Thailand is the Indian elephant, a subspecies of the Asian elephant."

giraffe =	"The giraffe's distinguishing characteristics are its extremely long neck and legs, horn-like ossicones, and spotted coat patterns. It is classified under the family Giraffidae, along with its closest extant relative, the okapi. Its scattered range extends from Chad in the north to South Africa in the south and from Niger in the west to Somalia in the east."

hamster =	"Hamsters feed primarily on seeds, fruits, vegetation, and occasionally burrowing insects. In the wild, they are crepuscular: they forage during the twilight hours. In captivity, however, they are known to live a conventionally nocturnal lifestyle, waking around sundown to feed and exercise. Physically, they are stout-bodied with distinguishing features that include elongated cheek pouches extending to their shoulders, which they use to carry food back to their burrows, as well as a short tail and fur-covered feet."

otter	= "Otters are highly intelligent, semi-aquatic members of the weasel family known for their playful nature and vital ecological role. Whether river-dwelling or marine, they act as keystone species. By controlling urchin populations, sea otters protect kelp forests, which sequester carbon and support marine biodiversity."

polar-bear = "The polar bear is a large bear native to the Arctic and nearby areas. It is closely related to the brown bear, and the two species can interbreed. The polar bear is the largest extant species of bear and land carnivore, with adult males weighing 300-800 kg. The polar bear is white- or yellowish-furred with black skin and a thick layer of fat."

rhino = "Rhinoceroses are some of the largest remaining megafauna: all weigh over half a tonne in adulthood. They have a herbivorous diet, small brains 400-600 g for mammals of their size, one or two horns, and a thick 1.5-5 cm, protective skin formed from layers of collagen positioned in a lattice structure. They generally eat leafy material."

snail = "Snails can be found in a very wide range of environments, including ditches, deserts, and the abyssal depths of the sea. Although land snails may be more familiar to laymen, marine snails constitute the majority of snail species, and have much greater diversity and a greater biomass. Numerous kinds of snail can also be found in fresh water."

mystery	= "The elephant is a contributor to Thai society. It has been an icon of Thai life for many centuries. The elephant, which it is possible to see found in every part of Thailand, is the Indian elephant, which is a subspecies of the Asian elephant. The Thai elephant has a considerable impact on culture. The elephant is the official national animal of Thailand."
          
# define the essay table, leaving rating and tags empty
essays = 
  table:  ID, EMOJI,    DOC,      LIKED, DISLIKED, TAGS
    row: "A", "🦡", badger,     false,   false,  ""
    row: "B", "🐳", blue-whale, false,   false,  ""
    row: "C", "🐒", chimpanzee, false,   false,  ""
    row: "D", "🐘", elephant,   false,   false,  ""
    row: "E", "🦒", giraffe,    false,   false,  ""
    row: "F", "🐹", hamster,    false,   false,  ""
    row: "G", "🦦", otter,      false,   false,  ""
    row: "H", "🐻‍❄️", polar-bear, false,   false,  ""
    row: "I", "🦏", rhino,      false,   false,  ""
    row: "J", "🐌", snail,      false,   false,  ""
    row: "K", "❓", mystery,    false,   false,  ""
  end
          
whale-essay = row-n(essays, 0)

fun essay-img(r): text(r["EMOJI"], 24, "black") end