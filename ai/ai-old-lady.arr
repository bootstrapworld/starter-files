use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")

corpus = ```There was an old lady who swallowed a fly

         There was an old lady who swallowed a fly
         I don't know why she swallowed a fly - perhaps she'll die!


         There was an old lady who swallowed a spider,
         That wriggled and wiggled and tiggled inside her;
         She swallowed the spider to catch the fly;
         I don't know why she swallowed a fly - Perhaps she'll die!


         There was an old lady who swallowed a bird;
         How absurd to swallow a bird.
         She swallowed the bird to catch the spider,
         She swallowed the spider to catch the fly;
         I don't know why she swallowed a fly - Perhaps she'll die!


         There was an old lady who swallowed a cat;
         Fancy that to swallow a cat!
         She swallowed the cat to catch the bird,
         She swallowed the bird to catch the spider,
         She swallowed the spider to catch the fly;
         I don't know why she swallowed a fly - Perhaps she'll die!


         There was an old lady that swallowed a dog;
         What a hog, to swallow a dog;
         She swallowed the dog to catch the cat,
         She swallowed the cat to catch the bird,
         She swallowed the bird to catch the spider,
         She swallowed the spider to catch the fly;
         I don't know why she swallowed a fly - Perhaps she'll die!


         There was an old lady who swallowed a cow,
         I don't know how she swallowed a cow;
         She swallowed the cow to catch the dog,
         She swallowed the dog to catch the cat,
         She swallowed the cat to catch the bird,
         She swallowed the bird to catch the spider,
         She swallowed the spider to catch the fly;
         I don't know why she swallowed a fly - Perhaps she'll die!


         There was an old lady who swallowed a horse...
         She's dead, of course!
         ```

# Use the contracts below to explore the lyrics

# generate-ngram-table :: String, Number -> Table
# build-lang-model :: String -> Model
# completions :: Model, String -> Table
# best-completion :: Model, String -> String
# add-next-word :: Model, String -> String
# generate-from :: Model, String -> Image