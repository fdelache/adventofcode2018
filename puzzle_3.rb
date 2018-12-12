require 'pry'

class Claim
	attr_reader :id, :x, :y, :w, :h

	def initialize(line)
		values = line.scan(/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/).first.map(&:to_i)
		@id, @x, @y, @w, @h = values
	end

	def intersects?(other_claim) 
		!intersection(other_claim).nil?
	end

	def intersection(other_claim)
		x_min = [x, other_claim.x].max
		x_max = [x + w, other_claim.x + other_claim.w].min

		y_min = [y, other_claim.y].max
		y_max = [y + h, other_claim.y + other_claim.h].min

		return nil if (x_max <= x_min) || (y_max <= y_min)

		Claim.new("#1 @ #{x_min},#{y_min}: #{x_max - x_min}x#{y_max - y_min}")
	end

	def square_representation
		representation = []
		(x..(x+w-1)).each do |i|
			(y..(y+h-1)).each do |j|
				representation << "#{i},#{j}"
			end
		end

		representation
	end

	alias_method :eql?, :==

	def ==(other)
		state == other.state
	end

	protected

	def state
		[@x, @y, @w, @h]
	end
end

class Puzzle3
	attr_reader :claims

	def initialize(claims)
		@claims = claims.map { |line| Claim.new(line) }
	end

	def intersection_area
		intersections = @claims.combination(2).map { |pair| pair.first.intersection(pair.last) }.compact
		intersections.reduce([]) { |accum, claim| accum + claim.square_representation }.uniq.size
	end

	def claim_without_intersection
		
		intersection_counts = @claims.combination(2).reduce(Hash.new(0)) do |accum, pair|
			
			first = pair.first
			second = pair.last

			if first.intersects?(second)
				accum["#{first.id}"] += 1
				accum["#{second.id}"] += 1
			elsif !accum.has_key?("#{first.id}")
				accum["#{first.id}"] = 0
			elsif !accum.has_key?("#{second.id}")
				accum["#{second.id}"] = 0
			end
			
			accum
		end

		intersection_counts.select { |k, v| v == 0 }
	end

	def solve
		puts "Day 3 puzzle 1 answer is: #{intersection_area}"
		puts "Day 2 puzzle 2 answer is: #{claim_without_intersection}"
	end

	def self.run
		puzzle = Puzzle3.new(File.readlines('data/day_3_input'))

		puzzle.solve
	end
end


