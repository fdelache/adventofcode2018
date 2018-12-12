require_relative 'test_helper'
require_relative '../puzzle_1'

class Puzzle1Test < Minitest::Test
	
	def test_get_frequency
		assert_equal 3, Puzzle1.new(["+1", "+1", "+1"]).get_end_frequency
		assert_equal 0, Puzzle1.new(["+1", "+1", "-2"]).get_end_frequency
		assert_equal -6, Puzzle1.new(["-1", "-2", "-3"]).get_end_frequency
	end

	def test_get_first_duplicate
		assert_equal 1, Puzzle1.get_first_duplicate([1, 2, 3, 1, 3])
		assert_nil Puzzle1.get_first_duplicate([1, 2, 3, 4, 5])
	end

	def test_get_first_duplicate_frequency
		assert_equal 0, Puzzle1.new(["+1", "-1"]).get_first_duplicate_frequency
		assert_equal 10, Puzzle1.new(["+3", "+3", "+4", "-2", "-4"]).get_first_duplicate_frequency
		assert_equal 5, Puzzle1.new(["-6", "+3", "+8", "+5", "-6"]).get_first_duplicate_frequency
		assert_equal 14, Puzzle1.new(["+7", "+7", "-2", "-7", "-4"]).get_first_duplicate_frequency
	end
end

