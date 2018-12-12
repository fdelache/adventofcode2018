require_relative 'test_helper'
require_relative '../puzzle_3'

class Puzzle3Test < Minitest::Test
	def test_claim_initialize
		claim = Claim.new("#12 @ 410,568: 27x24")
		assert_equal 410, claim.x
		assert_equal 568, claim.y
		assert_equal 27, claim.w
		assert_equal 24, claim.h
	end

	def test_claim_equality
		claim = Claim.new("#12 @ 410,568: 27x24")
		other = Claim.new("#12 @ 410,568: 27x24")

		assert_equal claim, other
	end

	def test_claim_intersection
		claim1 = Claim.new("#1 @ 1,3: 4x4")
		claim2 = Claim.new("#2 @ 3,1: 4x4")

		intersection = claim1.intersection(claim2)
		assert Claim.new("#1 @ 3,3: 2x2") == intersection
	end

	def test_square_representation
		claim1 = Claim.new("#1 @ 1,3: 4x4")
		assert_equal ["1,3", "1,4", "1,5", "1,6",
						"2,3", "2,4", "2,5", "2,6",
						"3,3", "3,4", "3,5", "3,6",
						"4,3", "4,4", "4,5", "4,6"], claim1.square_representation
	end

	def test_claim_without_intersection
		claims = ["#1 @ 1,3: 4x4",
			"#2 @ 3,1: 4x4",
			"#3 @ 5,5: 2x2"]

		assert_equal "3", Puzzle3.new(claims).claim_without_intersection.first[0]
	end
end

