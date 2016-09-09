require File.expand_path(File.dirname(__FILE__) + '/neo')

class BeginningTheSearch < Neo::Koan
  COUNT = 50

  # Build an array, containing the numbers 0-size, in random order
  def random_array(size = COUNT)
    (0..size).to_a.sort{ rand() - 0.5 }
  end

  # Ruby provides built-in methods for searching arrays--YOU ALMOST
  # ALWAYS WANT TO USE THESE! The search methods that we'll be
  # exploring are primarily for illustrating some important CS
  # concepts.
  def test_using_built_ins
    # this is a sorted array, that is, all the numbers are in order,
    # starting at 0
    array = (0..50).to_a
    assert_equal 51, array.size
    assert_equal array[50], array.last
    assert_equal array[0], array.first
    assert_equal 5, array[5]
    assert_equal 20, array[20]
    assert_equal 40, array[40]

    # use #find_index to return the array index of a value
    assert_equal 50, array.find_index(50)

    # you can also use #index
    assert_equal 50, array.index(50)
    assert_equal 20, array.index(20)

    # use #include? if you don't care about the location
    assert_equal true, array.include?(20)
    assert_equal false, array.include?(200)
  end

  # How could we implement find_index?
  #
  # 'array' is the array to search through, and value is the 
  # value we're looking for.
  def find_index_with_while(array, value)
    # Let's get really un-ruby-ish and use a while loop to step
    # through the array and compare each element.
    index = 0
    while array[index] != value and index < array.length
      # YOUR CODE HERE -- All you really need to do is step through
      # the array...
      index+=1
      # THINK ABOUT IT: When will your while loop break? Ever?
    end
    
    # We return the index... do you see the potential bug?
    index
  end

  def test_find_index_with_while
    array = (0..50).to_a
    rando = random_array(50)

    assert_equal find_index_with_while(array, 20), array.find_index(20)
    assert_equal find_index_with_while(array, 50), array.find_index(50)
    assert_equal find_index_with_while(array, 1), array.find_index(1)
    assert_equal find_index_with_while(rando, 20), rando.find_index(20)
    assert_equal find_index_with_while(rando, 50), rando.find_index(50)
    assert_equal find_index_with_while(rando, 1), rando.find_index(1)

    # What happens here? HINT: This is your bug.
    assert_equal 51, find_index_with_while(array, 200)
    assert_equal 51, find_index_with_while(rando, 200)
  end

  # Let's do it again with #each_with_index
  def find_index_with_each(array, value)
    final_index = nil
    array.each_with_index do |element, index|
      # YOUR CODE HERE -- What do you need to do at each step of the
      # loop?
      if element == value
        final_index = index
      end
    end
    final_index

    # THINK ABOUT IT: Does this do more or less work than
    # find_index_with_while?
    #
    # Will this version exhibit the same bug?

    # Also, does this loop break?
  end

  def test_find_index_with_each
    array = (0..50).to_a
    rando = random_array(50)

    assert_equal find_index_with_while(array, 20), array.find_index(20)
    assert_equal find_index_with_while(array, 50), array.find_index(50)
    assert_equal find_index_with_while(array, 1), array.find_index(1)
    assert_equal find_index_with_while(rando, 20), rando.find_index(20)
    assert_equal find_index_with_while(rando, 50), rando.find_index(50)
    assert_equal find_index_with_while(rando, 1), rando.find_index(1)

    # Again, what happens here?
    assert_equal nil, find_index_with_each(array, 200)
    assert_equal nil, find_index_with_each(rando, 200)
  end

end
