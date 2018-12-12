require 'pry-byebug'

digits = File.readlines('data/day_8_input').join.split(" ").map { |e| e.to_i }

class Node
	attr :child_count
	attr :metadata_count

	def initialize(child_count, metadata_count, digits)
		@child_count = child_count
		@metadata_count = metadata_count

		@children = []
		@metadata_entries = []

		child_count.times do |i|
			@children << Node.parse(digits)
		end

		metadata_count.times do |i|
			@metadata_entries << digits.shift
		end
	end

	def metadata_sum
		sum = @metadata_entries.reduce(&:+)
		@children.reduce(sum) { |accum, child| accum += child.metadata_sum }
	end

	def value
		return @metadata_entries.reduce(&:+) if @children.length == 0

		value = 0
		@metadata_entries.each do |index|
			value += @children[index-1].value if @children[index-1]
		end

		value
	end

	def self.parse(digits)
		child_count = digits.shift
		metadata_count = digits.shift

		Node.new(child_count, metadata_count, digits)
	end
end

test_node = Node.parse("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2".split(" ").map { |e| e.to_i } )
puts "Test #{test_node.value}"

node = Node.parse(digits)
puts "Metadata count: #{node.metadata_sum}"
puts "Part 2 - Value #{node.value}"

# binding.pry
