require 'pry-byebug'
require 'priority_queue'

class Cave
	attr_reader :depth
	attr_reader :target

	attr_reader :geologic_indexes
	attr_reader :erosion_levels

	ROCKY = 0
	WET = 1
	NARROW = 2

	ALL_TOOLS = [:torch, :climbing, :neither]

	def initialize(depth, target)
		@depth = depth
		@target = target
		@geologic_indexes = {}
		@erosion_levels = {}

		@geologic_indexes[[0,0]] = 0
		@geologic_indexes[target] = 0

		x_max, y_max = target
		(0..(y_max+300)).each do |y|
			(0..(x_max+300)).each do |x|
				type([x,y])
			end
		end
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
		@erosion_levels[position] ||= (geologic_index(position) + depth) % 20183
	end

	def type(position)
		erosion_level(position) % 3
	end

	def supported_tools(position)
		case type(position)
		when ROCKY
			[:climbing, :torch]
		when WET
			[:climbing, :neither]
		when NARROW
			[:torch, :neither]
		end
	end

	def cost(current_tool, pointA, pointB)
		cost = if supported_tools(pointB).include?(current_tool)
			[1, current_tool] 
		else
			[8, (supported_tools(pointB) & supported_tools(pointA)).first]
		end

		if (pointB == target) && (cost[1] != :torch)
			# binding.pry
			cost[0] += 7
			cost[1] = :torch
		end

		cost
	end

	def unvisited_neighbors(position, unvisited_positions)
		x, y = position
		[[x-1,y], [x, y-1], [x+1, y], [x, y+1]].select { |pos| ALL_TOOLS.any? { |tool| unvisited_positions.has_key?([pos, tool]) } }
	end

	def shortest_path
		active = PriorityQueue.new
		tools = Hash.new { :neither }
		found_distance = 0

		geologic_indexes.keys.each do |position|
			supported_tools(position).each do |tool|
				active.push([position, tool], Float::INFINITY)
			end
		end

		active.delete([[0,0], :climbing])
		active.change_priority([[0,0], :torch], 0)

		until active.empty?
			key, distance = active.delete_min
			current_position, current_tool = key
			
			found_distance = distance
			break if current_position == target

			# puts "current_position: #{current_position} - distance: #{distance} - with tool: #{current_tool}"
			# binding.pry
			neighbors = unvisited_neighbors(current_position, active)
			neighbors.each do |pos|
				tentative_distance, new_tool = cost(current_tool, current_position, pos)
				new_distance = distance + tentative_distance
				next if active.priority([pos, new_tool]).nil?
				if new_distance < active.priority([pos, new_tool])
					active.change_priority([pos, new_tool], new_distance)
				end
			end
		end

		puts "Found distance: #{found_distance}"
	end
end

# cave = Cave.new(510, [10, 10])
cave = Cave.new(11991, [6, 797])
# binding.pry
cave.shortest_path