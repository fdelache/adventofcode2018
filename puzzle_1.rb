require 'pry'

class Puzzle1
	attr_reader :lines

	def initialize(lines)
		@lines = lines
	end

	def self.get_end_frequency(lines)
		lines.reduce(0) { |accum, line| accum + line.to_i }
	end

	def self.get_first_duplicate_frequency(lines)
		seen_frequencies = [0]
		
		loop do
			seen_frequencies = lines.reduce(seen_frequencies) do |accum, line|
				frequency = (accum.empty? ? 0 : accum.last) + line.to_i
				accum << frequency
			end

			break if get_first_duplicate(seen_frequencies)
		end

		get_first_duplicate(seen_frequencies)
	end

	def self.get_first_duplicate(frequencies)
		seen_frequencies = {}
		frequencies.each do |freq|
			return freq if seen_frequencies.has_key?(freq)

			seen_frequencies[freq] = true
		end

		nil
	end

	def solve
		puts "Day 1 puzzle 1 answer is: #{Puzzle1.get_end_frequency(lines)}"
		puts "Day 1 puzzle 2 answer is: #{Puzzle1.get_first_duplicate_frequency(lines)}"
	end

	def self.run
		puzzle = Puzzle1.new(File.readlines('data/day_1_input'))

		puzzle.solve
	end
end
