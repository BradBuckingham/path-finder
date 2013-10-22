require 'set'
require 'pp'

DICT_FILE = "dictionary.txt"
MIN_WORD_SIZE = 2
MAX_WORD_SIZE = 5
A_TO_Z = ('a'..'z')

words = Set.new(File.readlines(DICT_FILE).map{|line| line.chomp})

word_graphs = {}

(MIN_WORD_SIZE..MAX_WORD_SIZE).each do |word_size|
  word_graphs[word_size] = {}

  words.select {|w| w.size == word_size}.each do |word|
    neighbors = []
    word_graphs[word_size][word] = neighbors

    (0...word_size).each do |index|
      A_TO_Z.select {|letter| letter != word[index]}.each do |new_letter|
        new_word = String.new(word)
        new_word[index] = new_letter

        neighbors << new_word if words.include? new_word
      end
    end
  end
end

#pp word_graphs
puts "Done building word graphs."

#
# Take input and try to find shortest path

print "Start word: "
start_word = gets.chomp.downcase

print "End word: "
end_word = gets.chomp.downcase

if start_word.size != end_word.size
  puts "Words must be of the same length!"
  exit 1
end

if start_word.size < MIN_WORD_SIZE || start_word.size > MAX_WORD_SIZE
  puts "Words must be longer than #{MIN_WORD_SIZE} characters and shorter than #{MAX_WORD_SIZE} characters"
  exit 1
end

unrecognized_words = [start_word, end_word].reject {|w| words.include? w}
unless unrecognized_words.empty?
  puts "Unrecognized word(s): " + unrecognized_words.join(", ")
  exit 1
end

word_graph = word_graphs[start_word.size]
bfs_queue = [start_word]
breadcrumbs = {start_word => nil}
visited_words = []

until bfs_queue.empty? do
  cur_word = bfs_queue.shift

  if cur_word == end_word
    found_path = []
    until cur_word.nil?
      found_path << cur_word
      cur_word = breadcrumbs[cur_word]
    end

    puts "  DONE: " + found_path.reverse.join(" -> ")
    exit 0
  end

  visited_words << cur_word

  # We don't enqueue _all_ of cur_word's neighbors into the bfs_queue. We
  # remove already-visited neighbors (else we'll loop indefinitely) and words
  # that are already enqueued (else we'll waste time revisiting some words)
  unvisited_neighbors = word_graph[cur_word] - visited_words - bfs_queue

  # Record breadcrumbs so we can backtrack when end_word is successfully found
  unvisited_neighbors.each {|n| breadcrumbs[n] = cur_word}

  bfs_queue.concat(unvisited_neighbors)
end

puts "No path found from #{start_word} to #{end_word}"
