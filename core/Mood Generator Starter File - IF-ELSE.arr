use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/main/core", "../libraries/core.arr")

# NOTE: This file makes use of emojis. Even though emojis look like images, they are actually characters in a string! They can be accessed from your keyboard, just like any other character...

# mood : String -> String
# consumes a mood, and produces the emoji for that mood

examples:
  mood("happy") is "😀"
  mood("sad")   is "😥"
  mood("angry") is "😡"
  mood("sick")  is "🤮"
end

fun mood(feeling):
  "❓"
end