require File.expand_path(File.dirname(__FILE__) + '/neo')

require './number_thinker'

# Set this to true if you need some debugging feedback
DEBUG = false

# For this koan, we're using a pre-built class called NumberThinker.
#
# When a NumberThinker is created it's passed a number. The
# NumberThinker generates a random number between 0 and the number it
# is given on creation.
#
# NumberThinker has two important methods:
#
# - #guess(n): Takes a number and returns :correct if n equals the number
# it's thinking of, :high if n > the number, and :low if n is too low.
#
# - #guesses: Returns the number of guesses that have been made.  
#
# You'll implement the NumberGuesser. The NumberGuesser tries to guess
# a number between 0 and max_number in as few guesses as possible,
# based on the result of the previous guesses (:high, :low, :correct).
# 
# Implement NumberGuesser#make_guess so that it guesses a number,
# given the following constraints:
#
# * Don't guess the same number twice
# * Get the number in as few guesses as possible
# * Use the feedback to refine your guess
#
class NumberGuesser
  attr_reader :guesses

  def initialize(max_number)
    @guesses = []
    @max_guess = max_number
    @min_guess = 0
  end

  def make_guess
    # HINT: Use the same guessing strategy that you would in real life!
    #
    # YOUR CODE HERE

    #--
    (@max_guess - @min_guess) / 2 + @min_guess
    #++

    0 # <- REPLACE THIS WITH A BETTER GUESS
  end

  def give_feedback(guessed_number, result)
    puts "guess: #{guessed_number} #{result}" if DEBUG
    # Save information about guesses to improve your next guess...
    #
    # YOUR CODE HERE

    #--
    @guesses << guessed_number
    if result == :high
      @max_guess = guessed_number
    elsif result == :low
      @min_guess = guessed_number
    end
    #++

    puts "min/max: #{@min_guess} #{@max_guess}" if DEBUG
  end
end

class AboutGuessingGame < Neo::Koan
  def run_game(thinker, guesser, times)
    finished = false
    1.upto(times) do
      g = guesser.make_guess
      result = thinker.guess g
      if result == :correct
        finished = true
      else
        guesser.give_feedback(g, result)
      end
    end
    finished
  end

  def test_guesser_finishes
    max = 100
    thinker = NumberThinker.new(max)
    guesser = NumberGuesser.new(max)

    result = run_game thinker, guesser, max

    puts "Answer: #{thinker.number}"
    puts "Total guesses: #{thinker.guesses}"

    # If this is your error, you need to improve
    # NumberGuesser#make_guess and NumberGuesser#give_feedback
    assert result, "You didn't get the answer (#{thinker.number}) in #{thinker.guesses} guesses!"
  end

  def test_guesser_is_optimal
    max = 100
    # Why this bound? (#ceil rounds the number up, BTW)
    bound = Math.log2(max).ceil
    thinker = NumberThinker.new(max)
    guesser = NumberGuesser.new(max)

    run_game thinker, guesser, max

    puts "Answer: #{thinker.number}"
    puts "Total guesses: #{thinker.guesses}"

    assert thinker.guesses < bound, "You need make < #{bound} guesses, you made #{thinker.guesses}"
  end

end
