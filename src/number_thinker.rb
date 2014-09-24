class NumberThinker
  attr_reader :guesses, :number

  def initialize(max)
    @number  = Random.rand(max)
    @guesses = 0
  end

  def guess(n)
    if n == @number
      :correct
    elsif n < @number
      @guesses += 1
      :low
    elsif n > @number
      @guesses += 1
      :high
    end
  end
end
