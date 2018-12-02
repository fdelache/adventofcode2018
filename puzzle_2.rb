require 'pry'

class Puzzle2
	attr_reader :lines

	def initialize(lines)
		@lines = lines
	end

	def self.count_two_and_three_times_letters(id)
		char_counts = id.each_char.with_object(Hash.new(0)) { |c, hash| hash[c] += 1 }
		[char_counts.has_value?(2) ? 1 : 0, char_counts.has_value?(3) ? 1 : 0]
	end

	def self.checksum_box_ids(ids)
		result = ids.reduce([0, 0]) do |accum, id|
			counts = count_two_and_three_times_letters(id)
			accum[0] += counts[0]
			accum[1] += counts[1]

			accum
		end

		result[0] * result[1]
	end

	def solve
		puts "Day 2 puzzle 1 answer is: #{Puzzle2.checksum_box_ids(lines)}"
		# puts "Answer to day 2 puzzle 2 is: #{get_first_duplicate_frequency(lines)}"
	end

	def self.run
		puzzle = Puzzle2.new(File.readlines('data/day_2_input'))

		puzzle.solve
	end
end


