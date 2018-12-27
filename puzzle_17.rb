require 'pry-byebug'

class Map
	attr_reader :map
	attr_reader :x_min, :x_max, :y_min, :y_max

	def self.parse(filepath)
		Map.new(File.readlines(filepath))
	end

	def initialize(lines)
		@map = {}

		@x_min = @y_min = Float::INFINITY
		@x_max = @y_max = 0

		@map[[500,0]] = '+'

		lines.each do |line|
			axe, pos, other_axe, start_pos, end_pos = line.match(/([xy])=(\d+), ([xy])=(\d+)\.\.(\d+)/)[1..5]
			case axe
			when 'x'
				x = pos.to_i
				(start_pos.to_i..end_pos.to_i).each do |y|
					@map[[x,y]] = '#'

					@x_min = x if x < @x_min
					@x_max = x if x > @x_max
					@y_min = y if y < @y_min
					@y_max = y if y > @y_max
				end
			when 'y'
				y = pos.to_i
				(start_pos.to_i..end_pos.to_i).each do |x|
					@map[[x,y]] = '#'

					@x_min = x if x < @x_min
					@x_max = x if x > @x_max
					@y_min = y if y < @y_min
					@y_max = y if y > @y_max
				end
			end
		end
	end

	def render
		(0..y_max).each do |y|
			((x_min-1)..(x_max+1)).each do |x|
				print "#{map[[x,y]] || '.'}"
			end
			puts ''
		end

		puts ''
	end

	def partial_render(position)
		puts "Map around #{position}"
		x_center , y_center = position
		((y_center-10)..(y_center+10)).each do |y|
			((x_center-30)..(x_center+30)).each do |x|
				print "#{map[[x,y]] || '.'}"
			end
			puts ''
		end

		puts ''
		gets
	end

	def right(position)
		x, y = position
		[x+1, y]
	end

	def left(position)
		x, y = position
		[x-1, y]
	end

	def down(position)
		x, y = position
		[x, y+1]
	end

	def up(position)
		x, y = position
		[x, y-1]
	end

	def outside?(position)
		x, y = position
		y > y_max
	end

	def free?(position)
		!position.nil? && map[position].nil?
	end

	def flow?(position)
		map[position] == '|'
	end

	def update_state(position, state)
		@map[position] = state

		# partial_render(position)
	end

	def next_down_flowable(position, direction)
		next_position = position
		loop do
			next_position = self.send(direction, next_position)
			return nil unless free?(next_position)

			if free?(down(next_position)) || flow?(down(next_position))
				return down(next_position)
			end
		end
	end

	def fill_direction(position, state, direction)
		next_position = position
		loop do
			next_position = self.send(direction, next_position)
			break unless free?(next_position)
			update_state(next_position, state)
			break if flow?(down(next_position))
		end
	end

	def fill(position, state)
		fill_direction(position, state, :left)
		fill_direction(position, state, :right)
		update_state(position, state)
	end

	def determine_state
		stack = []
		position = [500,0]

		loop do
			if outside?(down(position))
				update_state(position, '|')
				position = stack.pop
			elsif free?(down(position))
				stack.push(position)
				position = down(position)
			elsif flow?(down(position))
				update_state(position, '|')
				position = stack.pop
			else
				left_position = next_down_flowable(position, :left)
				right_position = next_down_flowable(position, :right)

				if left_position.nil? && right_position.nil?
					fill(position, '~')
					position = stack.pop
				elsif free?(left_position)
					stack.push(position)
					position = left_position
				elsif free?(right_position)
					stack.push(position)
					position = right_position
				elsif flow?(left_position) || flow?(right_position)
					fill(position, '|')
					position = stack.pop
				end
			end

			break if stack.empty?
		end
	end

	def determine_state_recursive(position)
		loop do
			break unless free?(position)

			if outside?(down(position))
				update_state(position, '|')
			elsif free?(down(position))
				determine_state_recursive(down(position))
			elsif flow?(down(position))
				update_state(position, '|')
			else
				left_position = next_down_flowable(position, :left)
				right_position = next_down_flowable(position, :right)

				if left_position.nil? && right_position.nil?
					fill(position, '~')
				elsif free?(left_position)
					determine_state_recursive(left_position)
				elsif free?(right_position)
					determine_state_recursive(right_position)
				elsif flow?(left_position) || flow?(right_position)
					fill(position, '|')
				end
			end
		end
	end

	def add_drop(position, direction)
		case direction
		when :down
			if flow?(down(position))
				return false if position == [500,0]

				@map[position] = '|'
				return true
			elsif free?(down(position))
				if outside?(down(position))
					@map[position] = '|'
					return true
				else
					add_drop(down(position), :down)
				end
			elsif free?(left(position))
				add_drop(left(position), :left)
			elsif free?(right(position))
				add_drop(right(position), :right)
			elsif flow?(left(position)) || flow?(right(position))
				@map[position] = '|'
				return true
			elsif position == [500,0]
				return false
			else
				@map[position] = '~'
				return true
			end
		when :left
			if flow?(down(position))
				@map[position] = '|'
				return true
			elsif free?(down(position))
				add_drop(down(position), :down)
			elsif free?(left(position))
				add_drop(left(position), :left)
			elsif flow?(left(position))
				@map[position] = '|'
				return true
			else
				@map[position] = '~'
				return true
			end
		when :right
			if flow?(down(position))
				@map[position] = '|'
				return true
			elsif free?(down(position))
				add_drop(down(position), :down)
			elsif free?(right(position))
				add_drop(right(position), :right)
			elsif flow?(right(position))
				@map[position] = '|'
				return true
			else
				@map[position] = '~'
				return true
			end
		end
	end

	def open_faucet
		determine_state

		# render
		puts "Water accessible squares: #{count_water}"
	end

	def first_clay
		position=[500,0]
		loop do
			position = down(position)
			break unless free?(position)
		end

		position
	end

	def count_still_water
		map.count { |k,v| v == "~" }
	end

	def count_water
		map.select { |k,v| k[1] <= y_max && k[1] >= y_min }
			.count { |k,v| v == '|' || v == '~' }
	end
end

SAMPLE=<<EOS
x=495, y=2..7
y=7, x=495..501
x=501, y=3..7
x=498, y=2..4
x=506, y=1..2
x=498, y=10..13
x=504, y=10..13
y=13, x=498..504
EOS

# map = Map.new(SAMPLE.split("\n"))
map = Map.parse('./data/day_17_input')
# map.render

# binding.pry
puts "First clay: #{map.first_clay}"
puts "Y_min: #{map.y_min}, Y_max: #{map.y_max}"
map.open_faucet
puts "Still water: #{map.count_still_water}"