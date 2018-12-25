require 'pry-byebug'

class Map
	attr_accessor :acres

	def self.parse(filepath)
		Map.new(File.readlines(filepath))
	end

	def initialize(data)
		@acres = Array.new(data.length) { Array.new }
		data.each_with_index do |line, y|
			line.chomp.each_char.each_with_index do |c, x|
				acres[y].push(c)
			end
		end
	end

	def adjacent_acres(x, y)
		adjacent=[]
		(-1..1).each do |dy|
			(-1..1).each do |dx|
				next if dx == 0 && dy == 0
				next if (x + dx) < 0 || (x + dx) >= acres[0].length
				next if (y + dy) < 0 || (y + dy) >= acres.length

				adjacent.push(acres.fetch(y + dy, nil)&.fetch(x + dx, nil))
			end
		end

		adjacent
	end

	def transform_acre(x, y)
		around = adjacent_acres(x, y)

		case acres[y][x]
		when '.'
			if around.count('|') >= 3
				'|'
			else
				'.'
			end
		when '|'
			if around.count('#') >= 3
				'#'
			else
				'|'
			end
		when '#'
			if around.count('|') >= 1 && around.count('#') >= 1
				'#'
			else
				'.'
			end
		end
	end

	def minute
		@acres = acres.each_with_index.map do |row, y|
			row.each_with_index.map do |acre, x|
				transform_acre(x,y)
			end
		end
	end

	def ten_minutes
		(1..10).each do |i|
			minute
			puts "Minute #{i}:"
			render
		end
	end

	def resource_value
		string = acres.join 
		wooded = string.count('|')
		lumber = string.count('#')

		wooded * lumber
	end

	def part1
		ten_minutes

		puts "Resource value: #{resource_value}"
	end

	def part2
		1000.times do |i|
			minute
			# if i % 10 == 0
				puts "Minute #{i}"
				puts "Resource value: #{resource_value}"
				# render
			# end
		end
	end

	def render
		acres.each do |row|
			row.each do |cell|
				print "#{cell}"
			end
			puts
		end
	end
end


SAMPLE=<<EOS
.#.#...|#.
.....#|##|
.|..|...#.
..|#.....#
#.#|||#|#|
...#.||...
.|....|...
||...#|.#|
|.||||..|.
...#.|..|.
EOS

# binding.pry
sample = Map.new(SAMPLE.split("\n"))
sample.part1

map = Map.parse('./data/day_18_input')
map.part1

map = Map.parse('./data/day_18_input')
map.part2

600: 219834
628: 219834
(1000000000 - 600) % (628-600) + 599