require 'pry'

class Puzzle2
	attr_reader :ids

	def initialize(ids)
		@ids = ids
	end

	def self.count_two_and_three_times_letters(id)
		char_counts = id.each_char.with_object(Hash.new(0)) { |c, hash| hash[c] += 1 }
		[char_counts.has_value?(2) ? 1 : 0, char_counts.has_value?(3) ? 1 : 0]
	end

	def checksum_box_ids
		result = ids.reduce([0, 0]) do |accum, id|
			counts = Puzzle2.count_two_and_three_times_letters(id)
			accum[0] += counts[0]
			accum[1] += counts[1]

			accum
		end

		result[0] * result[1]
	end

	def pairs_differ_by_one_letter?(pair)
		a = pair.first
		b = pair.last
		different_letter_count = 0
		a.each_char.with_index do |c, idx|
			different_letter_count += 1 if c != b[idx]
		end

		different_letter_count == 1
	end

	def get_one_letter_close_ids
		ids.combination(2).select do |pair|
			pairs_differ_by_one_letter?(pair)
		end.first
	end

	def get_close_ids_common_letters
		pair = get_one_letter_close_ids
		get_common_letters(pair)
	end

	def get_common_letters(pair)
		a = pair.first
		b = pair.last
		a.each_char.with_index.select do |c, idx|
			c == b[idx]
		end.map(&:first).join
	end

	def solve
		puts "Day 2 puzzle 1 answer is: #{checksum_box_ids}"
		puts "Day 2 puzzle 2 answer is: #{get_close_ids_common_letters}"
	end

	def self.run
		puzzle = Puzzle2.new(File.readlines('data/day_2_input'))

		puzzle.solve
	end
end


