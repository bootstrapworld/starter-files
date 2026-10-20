use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/main/ai", "../libraries/core.arr")

short-corpus = ```
she swallowed the cat to catch the bird
she swallowed the bird to catch the spider
```

corpus = ```
there was an old lady who swallowed a fly

there was an old lady who swallowed a fly
i don't know why she swallowed a fly 
perhaps she'll die

there was an old lady who swallowed a spider
that wriggled and jiggled and tickled inside her
she swallowed the spider to catch the fly
i don't know why she swallowed a fly
perhaps she'll die

there was an old lady who swallowed a bird
how absurd to swallow a bird
he swallowed the bird to catch the spider
that wriggled and jiggled and tickled inside her
she swallowed the spider to catch the fly
i don't know why she swallowed a fly
perhaps she'll die

there was an old lady who swallowed a cat
well fancy that
she swallowed a cat
she swallowed the cat to catch the bird
she swallowed the bird to catch the spider
that wriggled and jiggled and tickled inside her
she swallowed the spider to catch the fly
i don't know why she swallowed a fly 
perhaps she'll die
```

# Use the contracts below to explore the lyrics

# n-grams :: String -> Model
# stat-lang-model :: String -> Model
# completions :: Model, String -> Table
# suggestions :: Model, String -> Table
# choose-suggestion :: Model, String, Number -> String
# generate-text :: Model, Number -> String

m-short = stat-lang-model(short-corpus)
m = stat-lang-model(corpus)