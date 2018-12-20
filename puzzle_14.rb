class ScoreBoard
	attr_reader :scores
	attr_reader :elves
	attr_reader :recipe_number

	def initialize(recipe_number)
		@scores = [3, 7]
		@elves = [Elf.new(0), Elf.new(1)]
		@recipe_number = recipe_number
	end

	def new_recipes
		recipe_sum = elves.reduce(0) { |accum, e| accum += e.recipe(self) }
		recipe_sum.to_s.each_char do |c|
			@scores.push(c.to_i)
		end

		elves.each { |e| e.move(self) }
	end

	def ten_next_recipe
		loop do
			new_recipes

			break if scores.length >= (recipe_number + 10)
		end

		scores[recipe_number, 10].join
	end

	def number_of_recipe_before_digits
		found_digits = ""
		loop do
			new_recipes

			break if scores.length >= (recipe_number + 10) && found_digits = scores[recipe_number..-1].join.match(/(\d+?)#{recipe_number}/)
		end

		found_digits
	end
end

class Elf
	attr_reader :score_index

	def initialize(index)
		@score_index = index
	end

	def move(scoreboard)
		current_score = scoreboard.scores[score_index]
		move_count = 1 + current_score
		new_index = ((move_count % scoreboard.scores.length) + score_index) % scoreboard.scores.length
		@score_index = new_index
	end

	def recipe(scoreboard)
		scoreboard.scores[score_index]
	end
end

puts ScoreBoard.new(9).ten_next_recipe
puts ScoreBoard.new(5).ten_next_recipe
puts ScoreBoard.new(18).ten_next_recipe
puts ScoreBoard.new(2018).ten_next_recipe
puts ScoreBoard.new(293801).ten_next_recipe

puts "Part II"

puts ScoreBoard.new(9).number_of_recipe_before_digits
puts ScoreBoard.new(5).number_of_recipe_before_digits
puts ScoreBoard.new(18).number_of_recipe_before_digits
puts ScoreBoard.new(2018).number_of_recipe_before_digits
puts ScoreBoard.new(293801).number_of_recipe_before_digits
