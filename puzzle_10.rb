require 'pry-byebug'

test_data=<<EOS
position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>
EOS

class Position
	attr_reader :x, :y, :vx, :vy

	def self.parse(line)
		matcher = line.match(/position=<\s*(?<x>-?\d+),\s*(?<y>-?\d+)> velocity=<\s*(?<vx>-?\d+),\s*(?<vy>-?\d+)>/)
		Position.new(matcher[:x].to_i, matcher[:y].to_i, matcher[:vx].to_i, matcher[:vy].to_i)
	end

	def initialize(x, y, vx, vy)
		@x = x
		@y = y
		@vx = vx
		@vy = vy
	end

	def move
		@x += vx
		@y += vy
	end
end

def render_points(points)
	x_min = points.min_by { |p| p.x }.x
	y_min = points.min_by { |p| p.y }.y
	x_max = points.max_by { |p| p.x }.x
	y_max = points.max_by { |p| p.y }.y

	#render only if x_min..x_max is 100 chars large
	return false if x_max - x_min > 100

	puts "Position at #{$time} is"
	puts "-----------------------"
	
	(y_min..y_max).each do |y|
		(x_min..x_max).each do |x|
			under_point = points.select { |point| point.x == x && point.y == y }
			char_to_print = under_point.empty? ? " " : '#'
			print char_to_print
		end
		STDIN.flush
		puts ""
	end

	true
end

def move(points)
	points.each { |p| p.move }
end

points = File.readlines('./data/day_10_input').map { |line| Position.parse(line) }

$time = 0
loop do
	rendered = render_points(points)
	move(points)

	gets if rendered
	$time += 1
end