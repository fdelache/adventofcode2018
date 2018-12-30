
class Cave
	attr_reader :depth
	attr_reader :target

	attr_reader :geologic_indexes

	def initialize(depth, target)
		@depth = depth
		@target = target
		@geologic_indexes = {}

		@geologic_indexes[[0,0]] = 0
		@geologic_indexes[target] = 0

		sum = 0
		x_max, y_max = target
		(0..y_max).each do |y|
			(0..x_max).each do |x|
				sum += erosion_level([x,y]) % 3
			end
		end

		puts "Risk level: #{sum}"
	end

	def geologic_index(position)
		x, y = position
		
		@geologic_indexes[position] ||= if x == 0
			y * 48271
		elsif y == 0 
			x * 16807
		else
			erosion_level([x-1,y]) * erosion_level([x,y-1]) 
		end
	end

	def erosion_level(position)
		(geologic_index(position) + depth) % 20183
	end
end

Cave.new(11991, [6, 797])