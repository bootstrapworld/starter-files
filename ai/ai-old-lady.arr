use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/main/ai", "../libraries/core.arr")

document-1 = ```
she swallowed the cat to catch the bird she swallowed the bird to catch the spider
```

document-2 = ```
there was an old lady who swallowed a fly there was an old lady who swallowed a fly i don't know why she swallowed a fly perhaps she'll die there was an old lady who swallowed a spider that wriggled and jiggled and tickled inside her she swallowed the spider to catch the fly i don't know why she swallowed a fly perhaps she'll die there was an old lady who swallowed a bird how absurd to swallow a bird she swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her she swallowed the spider to catch the fly i don't know why she swallowed a fly perhaps she'll die there was an old lady who swallowed a cat well fancy that she swallowed a cat she swallowed the cat to catch the bird she swallowed the bird to catch the spider that wriggled and jiggled and tickled inside her she swallowed the spider to catch the fly i don't know why she swallowed a fly perhaps she'll die
```

# Use the contracts below to explore the lyrics

# n-grams :: String -> Table
# Given a corpus, make a table of n-grams, their sizes, and their counts

# stat-lang-model :: String -> Model
# Given a corpus, make a statistical language model (SLM)

# completions :: Model, String -> Table
# Given an SLM and a starting phrase, make a table of possible completions and their probabilities

# suggestions :: Model, String -> Table
# Given an SLM  and a starting phrase, make a table of all possible suggestions and their probabilities

# choose-suggestion :: Model, String, Number -> String
# Given an SLM, starting phrase and temperature, choose a next word

# generate-text :: Model, Number -> String
# Given an SLM and temperature, generate text one word at a time 

m-short = stat-lang-model(document-1)
m = stat-lang-model(document-2)
