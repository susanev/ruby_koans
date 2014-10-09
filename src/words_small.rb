class WordsSmall
  FILE = File.expand_path(File.dirname(__FILE__) + '/unsorted_words')

  def initialize
    @words = ["incasement", "strouthocamelian", "draughtswoman", "amotus", "haplont", "tractarian", "prefamiliarity", "tripleback", "selenic", "precausation", "flagroot", "kreis", "zootype", "ornithine", "torfel", "lypemania", "earnful", "astylar", "Chordeiles", "us", "micromotoscope"]
  end

  def remaining_words
    @words.length
  end

  def next_word
    @words.shift
  end
end
