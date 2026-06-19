use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")

corpus = ```
         There was an Old Lady who Swallowed a Fly

         There was an old lady who swallowed a fly,
         I don't know why she swallowed a fly - perhaps she'll die!

         There was an old lady who swallowed a spider
         That wriggled and jiggled and tickled inside her;
         She swallowed the spider to catch the fly;
         I don't know why she swallowed a fly - perhaps she'll die!

         There was an old lady who swallowed a bird;
         How absurd to swallow a bird!
         She swallowed the bird to catch the spider
         That wriggled and jiggled and tickled inside her,
         She swallowed the spider to catch the fly;
         I don't know why she swallowed a fly - perhaps she'll die!

         There was an old lady who swallowed a cat;
         Well, fancy that, she swallowed a cat!
         She swallowed the cat to catch the bird,
         She swallowed the bird to catch the spider
         That wriggled and jiggled and tickled inside her,
         She swallowed the spider to catch the fly;
         I don't know why she swallowed a fly - perhaps she'll die!
         ```

# Use the contracts below to explore the lyrics

# generate-ngrams :: String, Number -> Table
# build-lang-model :: String -> Model
# completions :: Model, String -> Table
# choose-completion :: Model, String, Number -> String
# generate-from :: Model, String -> String
