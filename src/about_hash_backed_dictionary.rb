require File.expand_path(File.dirname(__FILE__) + '/neo')

require './words'

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
    #--
    while word = @word_emitter.next_word do
      @backing_store[word] = true
    end
    #++
  end

  # This method should take a word and return true if it's in the
  # dictionary and false if it's not.
  def valid_word?(word)
    # WRITE THIS CODE
    #--
    @backing_store[word]
    #++
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

    assert __(true), dictionary.valid_word?("cat")
    assert __(true), dictionary.valid_word?("bat")
    assert __(true), dictionary.valid_word?("dictionary")
    assert __(false), dictionary.valid_word?("asasdfasdfasdf")
    assert __(false), dictionary.valid_word?("78943278943")
  end

  
  ## THINK ABOUT IT:
  #
  # How would you write a method to return words from the dictionary
  # in order? Is it possible? How would you write a method to tell you
  # what position a word had in the dictionary? Is this possible?
end
