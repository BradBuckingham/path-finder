require 'set'
require 'pp'

class PathFinder
  A_TO_Z = ('a'..'z')

  attr_reader :min_word_size, :max_word_size

  def initialize(dictionary_file)
    dict_lines = File.readlines(dictionary_file).map do |line|
      line.chomp!
      @min_word_size = [@min_word_size, line.size].compact.min
      @max_word_size = [@max_word_size, line.size].compact.max

      line
    end
    @dictionary_words = Set.new(dict_lines)
    @word_graphs = {}

    build_word_graphs
  end

  def build_word_graphs
    (@min_word_size..@max_word_size).each do |word_size|
      @word_graphs[word_size] = {}

      @dictionary_words.select {|w| w.size == word_size}.each do |word|
        neighbors = []
        @word_graphs[word_size][word] = neighbors

        (0...word_size).each do |index|
          A_TO_Z.select {|letter| letter != word[index]}.each do |new_letter|
            new_word = String.new(word)
            new_word[index] = new_letter

            neighbors << new_word if @dictionary_words.include? new_word
          end
        end
      end
    end
  end

  def find_shortest_path(start_word, end_word)

    # parameters should be validated before entering this method
    # so we bail if either word is invalid
    exit 1 unless validate_words(start_word, end_word)

    my_word_graph = @word_graphs[start_word.size]
    bfs_queue = [start_word]
    breadcrumbs = {start_word => nil}
    visited_words = []

    until bfs_queue.empty? do
      cur_word = bfs_queue.shift

      # We've found the end_word! Return full path by traversing back up through
      # the breadcrumbs until we find start_word (i.e., when we've found the root
      # aka, word with nil parent pointer)
      if cur_word == end_word
        found_path = []
        until cur_word.nil?
          found_path << cur_word
          cur_word = breadcrumbs[cur_word]
        end

        return found_path.reverse
      end

      visited_words << cur_word

      # We don't enqueue _all_ of cur_word's neighbors into the bfs_queue. We
      # remove already-visited neighbors (else we'll loop indefinitely) and words
      # that are already enqueued (else we'll waste time revisiting some words)
      unvisited_neighbors = my_word_graph[cur_word] - visited_words - bfs_queue

      # Record breadcrumbs so we can backtrack when end_word is successfully found
      unvisited_neighbors.each {|n| breadcrumbs[n] = cur_word}

      bfs_queue.concat(unvisited_neighbors)
    end

    return []
  end

  def validate_words(start_word, end_word)
    if start_word.size != end_word.size
      puts "Words must be of the same length!"
      return false
    end

    if start_word.size < @min_word_size || start_word.size > @max_word_size
      puts "Words must be longer than #{@min_word_size} characters and shorter than #{@max_word_size} characters"
      return false
    end

    unrecognized_words = [start_word, end_word].reject {|w| @dictionary_words.include? w}
    unless unrecognized_words.empty?
      puts "Unrecognized word(s): " + unrecognized_words.join(", ")
      return false
    end

    return true
  end
end



if __FILE__ == $0
  # This file is being invoked directy from command line (i.e., ruby path_finder.rb)

  if ARGV.size != 1
    puts "Please provide a single argument, the path to the dictionary file."
    exit 1
  end

  dictionary_file = ARGV.shift
  puts "Initializing PathFinder graphs with dictionary file '#{dictionary_file}'"

  init_start_time = Time.now
  path_finder = PathFinder.new(dictionary_file)
  init_end_time = Time.now

  puts "Done initializing PathFinder (#{init_end_time - init_start_time} sec)"

  # Take input and try to find shortest path. To quit, use Ctrl + c
  while(true)
    puts
    puts "-------------------------------------------------"
    print "Start word: "
    start_word = gets.chomp.downcase

    print "  End word: "
    end_word = gets.chomp.downcase
    puts

    next unless path_finder.validate_words(start_word, end_word)

    puts "Finding shortest path from '#{start_word}' to '#{end_word}'"
    search_start_time = Time.now
    shortest_path = path_finder.find_shortest_path(start_word, end_word)
    search_end_time = Time.now

    if shortest_path.any?
      puts "  PATH_FOUND (#{search_end_time - search_start_time} sec): " + shortest_path.join(" -> ")
    else
      puts "  NO_PATH_FOUND (#{search_end_time - search_start_time} sec)"
    end
  end
end
