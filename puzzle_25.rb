require 'pry-byebug'

class Point
	attr_reader :position

	attr_reader :connected_points

	def initialize(line)
		@connected_points = []
		@position = line.split(',').map(&:to_i)
	end

	def distance(other)
		x, y, z, t = position
		ox, oy, oz, ot = other.position

		(x - ox).abs + (y - oy).abs + (z - oz).abs + (t - ot).abs
	end

	def find_connected_points(all_points)
		all_points.each do |point|
			next if point == self

			@connected_points.push(point) if distance(point) <= 3
		end
	end

	def build_constellation(constellation)
		constellation.push(self)

		connected_points.each do |connected|
			unless constellation.include?(connected)
				connected.build_constellation(constellation)
			end
		end

		constellation
	end
end

class Puzzle
	attr_reader :points
	attr_reader :constellations

	def self.parse(filepath)
		self.new(File.readlines(filepath))
	end

	def initialize(data)
		@points = data.map { |line| Point.new(line) }
		@constellations = []
	end

	def build_constellations
		connect_points

		to_process = points.dup

		loop do
			break if to_process.empty?

			point = to_process.shift
			constellation = point.build_constellation([])
			to_process = to_process.delete_if { |other| constellation.include?(other) }

			constellations.push(constellation)
		end
	end

	def connect_points
		points.each { |point| point.find_connected_points(points) }
	end

	def count_constellations
		build_constellations

		constellations.size
	end

	# def count_constellations
	# 	to_process = points.dup
	# 	constellations = {}

	# 	loop do
	# 		break if to_process.empty?

	# 		point = to_process.shift
	# 		constellations[point] = [point]

	# 		to_process.delete_if do |other|
	# 			if constellations[point].any? { |po| po.distance(other) <= 3 }
	# 				constellations[point].push(other)
	# 				true
	# 			else
	# 				false
	# 			end
	# 		end
	# 	end

	# 	puts "Constellations: #{constellations.size}"
	# end
end

SAMPLE=<<EOS
 0,0,0,0
 3,0,0,0
 0,3,0,0
 0,0,3,0
 0,0,0,3
 0,0,0,6
 9,0,0,0
12,0,0,0
EOS

SAMPLE2=<<EOS
-1,2,2,0
0,0,2,-2
0,0,0,-2
-1,2,0,0
-2,-2,-2,2
3,0,2,-1
-1,3,2,2
-1,0,-1,0
0,2,1,-2
3,0,0,0
EOS

SAMPLE3=<<EOS
1,-1,0,1
2,0,-1,0
3,2,-1,0
0,0,3,1
0,0,-1,-1
2,3,-2,0
-2,2,0,0
2,-2,0,-1
1,-1,0,-1
3,2,0,2
EOS

SAMPLE4=<<EOS
1,-1,-1,-2
-2,-2,0,1
0,2,1,3
-2,3,-2,1
0,2,3,-2
-1,-1,1,-2
0,-2,-1,0
-2,2,3,-1
1,2,2,0
-1,-2,0,-2
EOS

binding.pry
puts "SAMPLE: #{Puzzle.new(SAMPLE.split("\n")).count_constellations}"
puts "SAMPLE2: #{Puzzle.new(SAMPLE2.split("\n")).count_constellations}"
puts "SAMPLE3: #{Puzzle.new(SAMPLE3.split("\n")).count_constellations}"
puts "SAMPLE4: #{Puzzle.new(SAMPLE4.split("\n")).count_constellations}"

puts "Part1: #{Puzzle.parse('./data/day_25_input').count_constellations}"

