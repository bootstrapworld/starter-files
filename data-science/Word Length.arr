use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")


# Define your text, and turn it into a table

source-text = "Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal. Now we are engaged in a great civil war, testing whether that nation, or any nation so conceived and so dedicated, can long endure. We are met on a great battle-field of that war. We have come to dedicate a portion of that field, as a final resting place for those who here gave their lives that that nation might live. It is altogether fitting and proper that we should do this. But, in a larger sense, we can not dedicate—we can not consecrate—we can not hallow—this ground. The brave men, living and dead, who struggled here, have consecrated it, far above our poor power to add or detract. The world will little note, nor long remember what we say here, but it can never forget what they did here. It is for us the living, rather, to be dedicated here to the unfinished work which they who fought here have thus far so nobly advanced. It is rather for us to be here dedicated to the great task remaining before us—that from these honored dead we take increased devotion to that cause for which they gave the last full measure of devotion—that we here highly resolve that these dead shall not have died in vain—that this nation, under God, shall have a new birth of freedom—and that government of the people, by the people, for the people, shall not perish from the earth."

each-word = string-split-all(source-text, " ")
words-table = [T.table-from-columns: {"word"; each-word}]

#########################################################
# Define some rows

word1 = words-table.row-n(0)
word2 = words-table.row-n(2)


#########################################################
# Define some helper functions

# word-length :: Row -> Number
# Consumes a row, and computes the length of the word
examples:
  word-length(word1) is 4
  word-length(word2) is 3
end
fun word-length(r): string-length(r["word"]) end

# not-short :: Row -> Boolean
# Consumes a row, and computes whether the word is
# longer than 3 letters
examples:
  not-short(word1) is true
  not-short(word2) is false
end
fun not-short(r): word-length(r) > 3 end

#########################################################
# Play with these tables!
word-lengths = words-table.build-column("length", word-length)
long-words = word-lengths.filter(not-short)