require File.expand_path(File.dirname(__FILE__) + '/neo')

require File.expand_path(File.dirname(__FILE__) + '/words')

# For this project, you're going to write a simple dictionary, along
# the lines of what you'd use for word validation in your Scrabble
# projec. You're given an object that emits one word at a time, and
# you need to turn that stream of words into a hash backed
# dictionary. You'll fill in the blanks in the HashDictionary class to
# make the tests pass below.
#
# The Words class has already been written and is what you're given as
# the word_emitter object. See the tests below for details on how the
# word_emitter is instantiated and passed to the HashDictionary.
class HashDictionary
  # word_emitter has two methods defined on it: #next_word and
  # #remaining_words. When there are no words left, #next_word will
  # return nil
  def initialize(word_emitter)
    @backing_store = {}
    @word_emitter  = word_emitter
    load_words
  end

  def load_words
    # WRITE THIS CODE
    while @word_emitter.remaining_words != 0
      @backing_store[@word_emitter.next_word] = {}
    end
  end

  # This method should take a word and return true if it's in the
  # dictionary and false if it's not.
  def valid_word?(word)
    # WRITE THIS CODE
    return @backing_store.include?(word)
  end

  def size
    @backing_store.size
  end
end

class AboutHashBackedDictionary < Neo::Koan
  def test_load
    w = Words.new
    count = w.remaining_words

    dictionary = HashDictionary.new(w)

    assert_equal w.remaining_words, 0
    assert_equal dictionary.size, count
    # When could the count and dictionary.size not be equal?
  end

  def test_valid_words
    w = Words.new
    dictionary = HashDictionary.new(w)

    assert_equal true, dictionary.valid_word?("cat")
    assert_equal true, dictionary.valid_word?("bat")
    assert_equal true, dictionary.valid_word?("dictionary")
    assert_equal false, dictionary.valid_word?("asasdfasdfasdf")
    assert_equal false, dictionary.valid_word?("78943278943")
  end

  
  ## THINK ABOUT IT:
  #
  # How would you write a method to return words from the dictionary
  # in order? Is it possible? How would you write a method to tell you
  # what position a word had in the dictionary? Is this possible?
end
