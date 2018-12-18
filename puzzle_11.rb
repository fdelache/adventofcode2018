require 'pry-byebug'

class Cell
	attr_reader :x, :y, :power

	def initialize(x, y, grid_serial_number)
		@x = x
		@y = y

		compute_power(grid_serial_number)
	end

	def compute_power(grid_serial_number)
		rack_id = x + 10
		power = ((rack_id * y) + grid_serial_number) * rack_id

		hundreds_digit = 0
		hundreds_digit = power.to_s[-3].to_i if power.to_s.length >=3

		@power = hundreds_digit - 5
	end
end

class Grid
	attr_reader :cells

	attr_reader :cache_power_cell_square

	def initialize(grid_serial_number)
		@cells = {}
		(1..300).each do |x|
			(1..300).each do |y|
				@cells[[x,y]] = Cell.new(x, y, grid_serial_number)
			end
		end

		@cache_power_cell_square = {}
	end

	def power_cell_square(x, y, square_size: 3)
		sum = 0

		if !cache_power_cell_square[[x-1,y,square_size]].nil?
			sum = (y..(y+square_size - 1)).reduce(cache_power_cell_square[[x-1,y,square_size]]) do |accum, suby|
				accum = accum - cells[[x-1,suby]].power + cells[[x+square_size-1, suby]].power
                                accum
			end
		else
			(x..(x+square_size - 1)).each do |x|
				(y..(y+ square_size - 1)).each do |y|
					sum += cells[[x,y]].power 
				end
			end
		end

		cache_power_cell_square[[x,y,square_size]] = sum

		sum
	end

	def find_max_cell_square(square_size: 3)
		max = 0
		found_x, found_y = 0
		(1..(300-square_size+1)).each do |y|
			(1..(300-square_size+1)).each do |x|
				power = power_cell_square(x, y, square_size: square_size)
				if power > max
					max = power 
					found_x = x
					found_y = y
				end
			end
		end

		puts "For square_size #{square_size} max is #{max} at #{found_x}, #{found_y}"
		[found_x, found_y, max]
	end

	def find_max_of_max
		# binding.pry
		found_x = 0
		found_y = 0
		found_max = 0
		found_square_size = 0
		minimum_square_size = 0

                (1..300).each do |square_size|
			break if square_size <= minimum_square_size

			x, y, max = find_max_cell_square(square_size: square_size)
			if max > found_max
				found_x = x
				found_y = y
				found_max = max
				found_square_size = square_size
				minimum_square_size = [minimum_square_size, Math.sqrt(max) / 2].max
			end
		end

		[found_x, found_y, found_square_size, found_max]
	end
end

p Grid.new(1309).find_max_of_max
