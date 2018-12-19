require 'pry-byebug'

Pot = Struct.new(:has_plant) do
	def print
		has_plant ? "#" : "."
	end
end

class Rule
	attr_reader :match_state
	attr_reader :next_pot_state

	def self.parse(line)
		matcher = line.match(/(?<match_state>[\.#]{5}) => (?<new_state>[\.#])/)
		next_pot_state = Pot.new(matcher[:new_state] == "#")

		match_state = matcher[:match_state]
		pot_state = []
		match_state.each_char do |c|
			pot_state << Pot.new(c == "#")
		end

		Rule.new(pot_state, next_pot_state)
	end

	def initialize(match_state, next_pot_state)
		@match_state = match_state
		@next_pot_state = next_pot_state
	end

	def applicable(pot_array)
		pot_array == match_state
	end
end

class Generation
	attr_reader :state
	attr_reader :number

	EMPTY_POT = Pot.new(false)

	def self.parse(line)
		state = Hash.new { |h,k| h[k] = EMPTY_POT }
		line.each_char.with_index do |c, i|
			state[i] = Pot.new(c == "#")
		end

		Generation.new(state)
	end

	def initialize(state)
		@state = state
		@number = 0
	end

	def fetch_pot(number)
		state.fetch(number, EMPTY_POT)
	end

	def next_generation(rules)
		# binding.pry
		next_state = {}
		min_number = state.select { |k,v| v.has_plant }.min_by { |num, pot| num }.first
		max_number = state.select { |k,v| v.has_plant }.max_by { |num, pot| num }.first
		((min_number-2)..(max_number+2)).each do |number|
			surrounding_pots = (-2..2).each_with_object([]) { |i, obj| obj << fetch_pot(number + i) }
			rule = rules.find { |r| r.applicable(surrounding_pots) }
			next_state[number] = rule&.next_pot_state || EMPTY_POT
		end

		@state = next_state
		@number += 1
	end

	def sum
		plants_only = state.select { |k,v| v.has_plant }
		plants_only.reduce(0) { |accum, p| accum += p.first }
	end

	def print
		puts "#{number}: #{state.keys.min} #{state.values.map(&:print).join}"
	end
end

# binding.pry
sample = File.readlines('data/day_12_input')
initial_state_line = sample.shift.match(/initial state: (.*)/)[1]
generation = Generation.parse(initial_state_line)

rules = sample.each_with_object([]) do |line, accum|
	next if line.length < 10

	accum << Rule.parse(line)
end

500.times { |i| generation.next_generation(rules); generation.print }
generation.print

# binding.pry
puts "After 50000000000 iterations, sum is #{generation.sum}"
