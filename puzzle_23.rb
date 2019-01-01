require 'pry-byebug'
class NanoBot
	attr_reader :radius
	attr_reader :position

	def initialize(radius, position)
		@radius = radius
		@position = position
	end

	def manhattan_distance(other_bot)
		distance(other_bot.position)
	end

	def in_range(other_bot)
		manhattan_distance(other_bot) <= radius
	end

	def distance(other_position)
		x, y, z = position
		ox, oy, oz = other_position

		(x - ox).abs + (y - oy).abs + (z - oz).abs
	end

	def spherical_coords
		x, y , z = position

		r = Math.sqrt(x * x + y * y + z * z)
		theta = Math.acos(z / r)
		phi = Math.atan2(y, x)

		[r, theta, phi]
	end

	def inspect
		"Bot #{position} - r: #{radius} - spherical coords: #{spherical_coords}"
	end
end

class Puzzle23
	attr_reader :bots

	def self.parse(filepath)
		self.new(File.readlines(filepath))
	end

	def initialize(data)
		@bots = []
		data.each do |line|
			x, y, z, r = line.match(/pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)/)[1..4].map(&:to_i)
			@bots.push(NanoBot.new(r, [x, y, z]))
		end
	end

	def part1
		strongest_bot = bots.max_by { |bot| bot.radius }

		bots.count do |bot|
			strongest_bot.in_range(bot)
		end
	end

	def part2
		positive_bots = bots.select { |bot| bot.position.all? { |val| val.positive? } }
		distances = positive_bots.flat_map { |bot| [[bot.distance([0,0,0]) - bot.radius, 1], [bot.distance([0,0,0]) + bot.radius, -1]] }
			.sort_by { |distance, _| distance }

		count = 0
		countMax = 0
		found_distance = 0

		distances.each do |distance, in_out|
			count += in_out

			if count > countMax
				countMax = count
				found_distance = distance
			end
		end

		found_distance
	end
end

SAMPLE=<<EOS
pos=<0,0,0>, r=4
pos=<1,0,0>, r=1
pos=<4,0,0>, r=3
pos=<0,2,0>, r=1
pos=<0,5,0>, r=3
pos=<0,0,3>, r=1
pos=<1,1,1>, r=1
pos=<1,1,2>, r=1
pos=<1,3,1>, r=1
EOS

# puzzle = Puzzle23.new(SAMPLE.split("\n"))
# binding.pry
puzzle = Puzzle23.parse('./data/day_23_input')
puts "Part1: #{puzzle.part1}"

puts "Part2: #{puzzle.part2}"