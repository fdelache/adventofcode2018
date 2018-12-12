require 'pry-byebug'

Point = Struct.new(:id, :x, :y)

def manhattan_distance(x1, y1, x2, y2)
	(x1 - x2).abs + (y1 - y2).abs
end

def parse_point_line(line, global_id)
	matcher = line.match(/(\d+), (\d+)/)
	if matcher
		Point.new(global_id, matcher[1].to_i, matcher[2].to_i)
	else
		nil
	end
end

module Enumerable
	def mins_by
		minimums = []
		min_value = nil
		self.each do |e|
			value = yield e

			if minimums.empty?
				minimums << e
				min_value = value
			else
				if value < min_value
					minimums.clear
					minimums << e
					min_value = value
				elsif value == min_value
					minimums << e
				end
			end
		end

		minimums
	end
end

point_id = "A"
$data_points = File.readlines('data/day_6_input').reduce([]) do |accum, line|
	accum << parse_point_line(line, point_id)
	point_id = point_id.next

	accum
end

p $data_points

#compute bounding box
$x_min = $data_points.min_by { |point| point.x }.x
$x_max = $data_points.max_by { |point| point.x }.x
$y_min = $data_points.min_by { |point| point.y }.y
$y_max = $data_points.max_by { |point| point.y }.y

puts "Bounding box: #{$x_min} #{$x_max} #{$y_min} #{$y_max}"

def closest_point_id(x, y)
	closest_points = $data_points.mins_by { |point| manhattan_distance(x, y, point.x, point.y) }
	if closest_points.length == 1
		closest_points.first.id 
	else
		"."
	end
end

points_area=Hash.new(0)
infinite_ids=[]

($x_min..$x_max).each do |x|
	($y_min..$y_max).each do |y|
		# binding.pry
		# puts "Compute id for [#{x}, #{y}]"
		closest_point = closest_point_id(x,y)
		points_area[closest_point] += 1
		# puts "So far #{points_area}" if y == $y_min

		# Keep track of infinite ids
		if x == $x_min || x == $x_max || y == $y_min || y == $y_max
			infinite_ids << closest_point
		end
	end
end

infinite_ids.uniq!

puts "infinite_ids: #{infinite_ids}"

scoped_points_area = points_area.reject { |id, count| infinite_ids.include?(id) || id == "." }
p scoped_points_area.max_by { |id, count| count }


region_area = 0
region_points = []
($x_min..$x_max).each do |x|
	($y_min..$y_max).each do |y|
		sum_distances = $data_points.map { |point| manhattan_distance(x, y, point.x, point.y) }
							.reduce(&:+)

		if sum_distances < 10000
			region_area += 1
			region_points << Point.new("", x, y)
		end
	end
end

puts "Region size is #{region_area}"