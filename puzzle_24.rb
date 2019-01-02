require 'pry-byebug'

class Group
	attr_reader :alive_units, :unit_hit_points, :immune_to, :weak_to, :attack_damage, :attack_type, :initiative
	attr_reader :id, :army
	attr_reader :target

	def initialize(line, army, id, boost = 0)
		@id = id
		@army = army

		weak_to_regex=/weak to (?<weak_to>[^;]+)/
		immune_to_regex=/immune to (?<immune_to>[^;]+)/

		regex=/(?<unit_count>\d+) units each with (?<hit_points>\d+) hit points (?:\((?<immune_weak>[^\)]*)\) )?with an attack that does (?<attack_damage>\d+) (?<attack_type>\b\w+\b) damage at initiative (?<initiative>\d+)/
		match_data = line.match(regex)

		@alive_units = match_data[:unit_count].to_i
		@unit_hit_points = match_data[:hit_points].to_i
		@immune_to = @weak_to = []
		unless match_data[:immune_weak].nil?
			immune_match = match_data[:immune_weak].match(immune_to_regex)
			weak_match = match_data[:immune_weak].match(weak_to_regex)

			@immune_to = immune_match ? immune_match[:immune_to].split(', ') : []
			@weak_to = weak_match ? weak_match[:weak_to].split(', ') : []
		end

		@attack_damage = match_data[:attack_damage].to_i + boost
		@attack_type = match_data[:attack_type]
		@initiative = match_data[:initiative].to_i
	end

	def effective_power
		alive_units * attack_damage
	end

	def max_damage(defendant)
		max_damage = effective_power
		max_damage = 0 if defendant.immune_to.include?(attack_type)
		max_damage = max_damage * 2 if defendant.weak_to.include?(attack_type)

		max_damage
	end

	def defend(attacker)
		max_damage = attacker.max_damage(self)
		dead_units = [alive_units, max_damage / unit_hit_points].min

		@alive_units -= dead_units

		# puts "#{attacker.army} #{attacker.id} attacks #{army} #{id} killing #{dead_units}"
	end

	def attack
		return false if target.nil?

		before = target.alive_units
		target.defend(self)
		after = target.alive_units

		before != after
	end

	def alive?
		alive_units.positive?
	end

	def alive_points
		alive_units * unit_hit_points
	end

	def select_target(opponents)
		@target = opponents.sort do |a,b|
			tmp = max_damage(a) <=> max_damage(b)
			tmp = tmp == 0 ? a.effective_power <=> b.effective_power : tmp
			tmp == 0 ? a.initiative <=> b.initiative : tmp
		end.reverse.first

		unless target.nil?
			@target = nil if max_damage(target) == 0
		end

		# unless target.nil?
		# 	puts "#{army} group #{id} [#{alive_units} units alive] will attack #{target.id} with #{max_damage(target)} damage [#{target.id} still has #{target.alive_points} points]"
		# end

		target
	end
end

class Puzzle
	attr_reader :immune_groups, :infection_groups

	def self.parse(filepath)
		self.new(File.readlines(filepath))
	end

	def initialize(data, boost = 0)
		@immune_groups = []
		@infection_groups = []

		data.shift
		count = 0
		loop do
			line = data.shift.chomp
			break if line.empty?
			count += 1
			@immune_groups.push(Group.new(line, :Immune, count, boost))
		end

		data.shift
		count = 0
		loop do
			line = data.shift
			break if line.nil?
			count += 1
			@infection_groups.push(Group.new(line.chomp, :Infection, count))
		end
	end

	def immune_groups
		@immune_groups.select(&:alive?)
	end

	def infection_groups
		@infection_groups.select(&:alive?)
	end

	def target_selection
		ordered_groups = (immune_groups + infection_groups).sort do |a, b|
				tmp = a.effective_power <=> b.effective_power
				tmp == 0 ? a.initiative <=> b.initiative : tmp
		end.reverse

		remaining_immune = immune_groups.dup
		remaining_infection = infection_groups.dup

		ordered_groups.each do |group|
			opponents = remaining_immune
			opponents = remaining_infection if immune_groups.include?(group)

			target = group.select_target(opponents)
			opponents.delete(target)
		end
	end

	def fight
		(immune_groups + infection_groups).sort do |a, b|
				a.initiative <=> b.initiative
		end.reverse.map(&:attack).any? { |fight| fight == true }
	end

	def combat
		alive_count = 0

		loop do
			break if immune_groups.empty? || infection_groups.empty?

			target_selection

			break unless fight

			# puts
		end

		(immune_groups + infection_groups).reduce(0) { |sum, group| sum += group.alive_units }
	end

	def part1
		puts "Part 1: #{combat}"
	end

	def immune_alive_units
		immune_groups.reduce(0) { |sum, group| sum += group.alive_units }
	end

	def immune_wins?
		combat

		immune_alive_units.positive? && infection_groups.empty?
	end
end

SAMPLE=<<EOS
Immune System:
17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3

Infection:
801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
4485 units each with 2961 hit points (weak to fire, cold; immune to radiation) with an attack that does 12 slashing damage at initiative 4
EOS

binding.pry
# puzzle = Puzzle.new(SAMPLE.split("\n"))
puzzle = Puzzle.parse('./data/day_24_input')
puzzle.part1

data = File.readlines('./data/day_24_input')
boosts = (1..100)
result = boosts.bsearch do |boost|
	puts "Trying with boost #{boost}"
	Puzzle.new(data.dup, boost).immune_wins?
end

puts "Boost found: #{result}"
puzzle = Puzzle.new(data.dup, result)
puzzle.combat
puts "Part2: #{puzzle.immune_groups} - #{puzzle.infection_groups}"