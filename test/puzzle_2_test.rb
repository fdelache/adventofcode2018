require_relative 'test_helper'
require_relative '../puzzle_2'

class Puzzle2Test < Minitest::Test
	def test_count_letters
		assert_equal [0, 0], Puzzle2.count_two_and_three_times_letters("abcdef")
		assert_equal [1, 1], Puzzle2.count_two_and_three_times_letters("bababc")
		assert_equal [1, 0], Puzzle2.count_two_and_three_times_letters("abbcde")
		assert_equal [0, 1], Puzzle2.count_two_and_three_times_letters("abcccd")
		assert_equal [1, 0], Puzzle2.count_two_and_three_times_letters("aabcdd")
		assert_equal [1, 0], Puzzle2.count_two_and_three_times_letters("abcdee")
		assert_equal [0, 1], Puzzle2.count_two_and_three_times_letters("ababab")
	end

	def test_checksum
		assert_equal 12, Puzzle2.new(["abcdef", "bababc", "abbcde", "abcccd", "aabcdd", "abcdee", "ababab"]).checksum_box_ids
	end

	def test_get_one_letter_close_ids
		assert_equal ["fghij", "fguij"], Puzzle2.new(["abcde", "fghij", "klmno", "pqrst", "fguij", "axcye", "wvxyz"])
								.get_one_letter_close_ids
	end

	def test_get_close_ids_common_letter
		assert_equal "fgij", Puzzle2.new(["abcde", "fghij", "klmno", "pqrst", "fguij", "axcye", "wvxyz"])
								.get_close_ids_common_letters
	end
end

