require 'pry-byebug'

class Room
	attr_reader :adjacent_rooms
	attr_reader :position

	def initialize(position)
		@adjacent_rooms = []
		@position = position
	end

	def add(other_room)
		unless adjacent_rooms.include?(other_room)
			@adjacent_rooms.push(other_room)
			other_room.add(self)
		end
	end

	def has_east?
		adjacent_rooms.any? { |other| other.position[0] > position[0] }
	end

	def has_south?
		adjacent_rooms.any? { |other| other.position[1] > position[1] }
	end
end

class Map
	attr_reader :root
	attr_reader :rooms

	def self.parse(filepath)
		Map.new(File.readlines(filepath).first.chomp)
	end

	def initialize(routes)
		@rooms = {}
		@root = Room.new([0,0])
		@rooms[[0,0]] = root
		parent_rooms = []

		visit_room([0,0], routes, parent_rooms)
	end

	def visit_room(position, routes, parent_rooms)
		loop do
			break if routes.empty?

			direction = routes[0]
			routes = routes[1..-1]

			case direction
			when /[ENWS]/
				previous_position = position
				position = self.send(direction.downcase.to_sym, position)
				new_room = add_room(position, previous_position)
			when '('
				parent_rooms.push(rooms[position])
			when '|'
				position = parent_rooms[-1].position
			when ')'
				position = parent_rooms.pop.position
			end
		end
	end

	def add_room(position, previous_position)
		@rooms[position] ||= Room.new(position)
		@rooms[previous_position].add(@rooms[position])

		@rooms[position]
	end

	def n(position)
		x, y = position
		[x, y-1]
	end

	def s(position)
		x, y = position
		[x, y+1]
	end

	def e(position)
		x, y = position
		[x+1, y]
	end

	def w(position)
		x, y = position
		[x-1, y]
	end

	def part1
		compute_distances.values.max_by { |v| v }
	end

	def part2
		compute_distances.values.select { |distance| distance >= 1000 }
							.count
	end

	def compute_distances
	    distances = {}

	    positions_to_process = [root.position]
	    distance = 0
	    distances[root.position] = distance

	    loop do
	      position = positions_to_process.shift
	      distance = distances[position]

	      rooms[position].adjacent_rooms.each do |room|
	        adjacent_position = room.position
	        if distances[adjacent_position].nil?
	          distances[adjacent_position] = distance + 1
	          positions_to_process.push(adjacent_position)
	        end
	      end

	      break if positions_to_process.empty?
	    end

	    distances
	end

	def render
		x_min = rooms.keys.min_by { |k| k[0] }[0]
		x_max = rooms.keys.max_by { |k| k[0] }[0]
		y_min = rooms.keys.min_by { |k| k[1] }[1]
		y_max = rooms.keys.max_by { |k| k[1] }[1]

		puts '#' * ((x_max-x_min+1) * 2 + 1)
		(y_min..y_max).each do |y|
			print '#'
			(x_min..x_max).each do |x|
				print rooms[[x,y]].nil? ? "#" : (x == 0 && y == 0) ? 'X' : '.'
				print rooms[[x,y]].has_east? ? '|' : '#'
			end
			puts ''

			print '#'
			(x_min..x_max).each do |x|
				print rooms[[x,y]].has_south? ? "-" : "#"
				print '#'
			end
			puts ''
		end
	end
end

SAMPLE='^ENWWW(NEEE|SSE(EE|N))$'
SAMPLE2 = '^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$'
SAMPLE4 = '^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$'
SAMPLE5 = '^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$'

# binding.pry
# map = Map.new(SAMPLE5)
map = Map.parse('./data/day_20_input')
# map.render
puts "Part 1: #{map.part1}"
puts "Part 2: #{map.part2}"