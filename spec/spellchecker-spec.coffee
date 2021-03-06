SpellChecker = require '../lib/spellchecker'

describe "SpellChecker", ->
  describe ".isMisspelled(word)", ->
    it "returns true if the word is mispelled", ->
      expect(SpellChecker.isMisspelled('wwoorrdd')).toBe true

    it "returns false if the word isn't mispelled", ->
      expect(SpellChecker.isMisspelled('word')).toBe false

    it "throws an exception when no word specified", ->
      expect(-> SpellChecker.isMisspelled()).toThrow()

  describe ".checkSpelling(string)", ->
    it "returns an array of character ranges of misspelled words", ->
      string = "cat caat dog dooog"

      expect(SpellChecker.checkSpelling(string)).toEqual [
        {start: 4, end: 8},
        {start: 13, end: 18},
      ]

    it "accounts for UTF16 pairs", ->
      string = "😎 cat caat dog dooog"

      expect(SpellChecker.checkSpelling(string)).toEqual [
        {start: 7, end: 11},
        {start: 16, end: 21},
      ]

    it "accounts for other non-word characters", ->
      string = "'cat' (caat. <dog> :dooog)"
      expect(SpellChecker.checkSpelling(string)).toEqual [
        {start: 7, end: 11},
        {start: 20, end: 25},
      ]

    it "does not treat non-english letters as word boundaries", ->
      SpellChecker.add("cliché")
      expect(SpellChecker.checkSpelling("what cliché nonsense")).toEqual []

    it "handles words with apostrophes", ->
      string = "doesn't isn't aint hasn't"
      expect(SpellChecker.checkSpelling(string)).toEqual [
        {start: string.indexOf("aint"), end: string.indexOf("aint") + 4}
      ]

      string = "you say you're 'certain', but are you really?"
      expect(SpellChecker.checkSpelling(string)).toEqual []

      string = "you say you're 'sertan', but are you really?"
      expect(SpellChecker.checkSpelling(string)).toEqual [
        {start: string.indexOf("sertan"), end: string.indexOf("',")}
      ]

    it "handles invalid inputs", ->
      expect(SpellChecker.checkSpelling("")).toEqual []
      expect(-> SpellChecker.checkSpelling()).toThrow("Bad argument")
      expect(-> SpellChecker.checkSpelling(null)).toThrow("Bad argument")
      expect(-> SpellChecker.checkSpelling({})).toThrow("Bad argument")

  describe ".getCorrectionsForMisspelling(word)", ->
    it "returns an array of possible corrections", ->
      corrections = SpellChecker.getCorrectionsForMisspelling('worrd')
      expect(corrections.length).toBeGreaterThan 0
      expect(corrections.indexOf('word')).toBeGreaterThan -1

    it "throws an exception when no word specified", ->
      expect(-> SpellChecker.getCorrectionsForMisspelling()).toThrow()

  describe ".add(word)", ->
    it "allows words to be added to the dictionary", ->
      expect(SpellChecker.isMisspelled('wwoorrdd')).toBe true
      SpellChecker.add('wwoorrdd')
      expect(SpellChecker.isMisspelled('wwoorrdd')).toBe false

    it "throws an error if no word is specified", ->
      errorOccurred = false
      try
        Spellchecker.add()
      catch
        errorOccurred = true
      expect(errorOccurred).toBe true

  describe ".getAvailableDictionaries()", ->
    return if process.platform is 'linux'

    it "returns an array of string dictionary names", ->
      dictionaries = SpellChecker.getAvailableDictionaries()
      expect(Array.isArray(dictionaries)).toBe true

      # Dictionaries do not appear to be available on AppVeyor
      unless process.platform is 'win32' and (process.env.CI or process.env.SPELLCHECKER_PREFER_HUNSPELL)
        expect(dictionaries.length).toBeGreaterThan 0

      for dictionary in dictionaries.length
        expect(typeof dictionary).toBe 'string'
        expect(diction.length).toBeGreaterThan 0

  describe ".setDictionary(lang, dictDirectory)", ->
    it "sets the spell checker's language, and dictionary directory", ->
      awesome = true
      expect(awesome).toBe true
