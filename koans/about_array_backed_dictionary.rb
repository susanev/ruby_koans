require File.expand_path(File.dirname(__FILE__) + '/neo')
require File.expand_path(File.dirname(__FILE__) + '/words')
require File.expand_path(File.dirname(__FILE__) + '/words_small')

# We're now going to build an alternate dictionary using an array. The
# goal is to maintain a sorted array which we will use as our backing
# store. To do so, we want to insert every new word from the word
# emitter into it's correct position alphabetically as it's
# emitted. This is a variation on an insertion sort.
#
# The Words class has already been written and is what you're given as
# the word_emitter object. See the tests below for details on how the
# word_emitter is instantiated and passed to the ArrayDictionary.
class ArrayDictionary
  # word_emitter has two methods defined on it: #next_word and
  # #remaining_words. When there are no words left, #next_word will
  # return nil
  def initialize(word_emitter)
    @backing_store = []
    @word_emitter  = word_emitter
    load_words
  end

  def load_words
    # We want to load the words into the correct position one by one
    # as they are emitted.
    #
    # DO NOT LOAD THE WHOLE DICTIONARY INTO AN ARRAY AND SORT IT!
    # (Why could we have this type of constraint?)
    #
    # How could we find the position of a word in the array without
    # using Array#find_index? HINT: We wrote our own in
    # about_beginning_the_search
    #
    # WRITE THIS CODE 
    while @word_emitter.remaining_words != 0
      new_word = @word_emitter.next_word
      if @backing_store.length == 0 
        @backing_store[0] = new_word
      elsif new_word.downcase < @backing_store.first.downcase
        @backing_store.insert(0, new_word)
      elsif new_word.downcase > @backing_store.last.downcase
        @backing_store << new_word
      else
        min = 0
        max = @backing_store.length
        mid = (max+min)/2+min
        while max - min > 1
          if new_word.downcase > @backing_store[mid].downcase
            min = mid
          else
            max = mid
          end
          mid = (max+min)/2
        end
        @backing_store.insert(mid+1, new_word)

        # @backing_store.each_with_index do |word, index|
        #   if new_word.downcase > @backing_store[index].downcase && new_word.downcase < @backing_store[index+1].downcase
        #     @backing_store.insert(index+1, new_word)
        #     break
        #   end
        # end
      end
    end
  end

  # This method should take a word and return true if it's in the
  # dictionary and false if it's not.
  # 
  def valid_word?(word)
    # WRITE THIS CODE
    return @backing_store.include?(word)
  end

  def size
    @backing_store.size
  end
end

class AboutArrayBackedDictionary < Neo::Koan
  def test_load_small
    w = WordsSmall.new
    count = w.remaining_words

    dictionary = ArrayDictionary.new(w)

    assert_equal w.remaining_words, 0
    assert_equal dictionary.size, count
    # When could the count and dictionary.size not be equal?
  end

  def test_valid_words_small
    w = WordsSmall.new
    dictionary = ArrayDictionary.new(w)

    assert_equal true, dictionary.valid_word?("earnful")
    assert_equal true, dictionary.valid_word?("astylar")
    assert_equal false, dictionary.valid_word?("dictionary")
    assert_equal false, dictionary.valid_word?("78943278943")
  end

  def test_load
    w = Words.new
    count = w.remaining_words

    puts "*" * 80
    puts "LOADING the big dictionary"
    puts "If you used linear search for insertion, this may take a while..."
    dictionary = ArrayDictionary.new(w)

    assert_equal w.remaining_words, 0
    assert_equal dictionary.size, count
    # When could the count and dictionary.size not be equal?
  end

  def test_valid_words
    w = Words.new
    dictionary = ArrayDictionary.new(w)

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
