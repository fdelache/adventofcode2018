require 'pry-byebug'

def parseline(line)
	matcher = line.match(/Step ([A-Z]) must be finished before step ([A-Z]) can begin./)
	[matcher[1], matcher[2]]
end

class Step
	attr_reader :children_steps
	attr_reader :parent_steps

	attr_reader :id

	def initialize(id)
		@id = id
		@children_steps = []
		@parent_steps = []
	end

	def add_child_step(step)
		@children_steps << step
		step.add_parent_step(self)
	end

	def add_parent_step(step)
		@parent_steps << step
	end

	def inspect
		"#{id} - Completed_at #{completed_at}"
	end

	def duration
		60 + (id.ord - "A".ord + 1)
	end

	def process(time)
		@process_time = time
	end

	def completed_at
		(@process_time + duration) if @process_time
	end

	def processing?(time)
		time > @process_time if @process_time
	end

	def completed?(time)
		(completed_at <= time) if completed_at
	end
end

$rules = Hash.new { |hash, key| hash[key] = Step.new(key) }

File.readlines('data/day_7_input').map { |line| parseline(line) }.each do |first, second|
	$rules[first].add_child_step($rules[second])
end

first_steps = $rules.select { |id, step| step.parent_steps.empty? }.values

puts "First steps: #{first_steps}"
def walk_through_steps(next_steps, visited_nodes)
	sorted_next_steps = next_steps.uniq.sort_by { |step| step.id }
	next_step = sorted_next_steps.shift

	unless next_step.nil?
		visited_nodes << next_step
		next_step.id + walk_through_steps(sorted_next_steps + visitable_nodes(next_step.children_steps, visited_nodes), visited_nodes)
	else
		""
	end
end

def visitable_nodes(node_list, visited_nodes)
	node_list.select { |node| (node.parent_steps - visited_nodes).empty? }
end

puts "Ordered steps: #{walk_through_steps(first_steps, [])}"

class Worker
	attr_reader :free_at
	attr_reader :processed_step

	def initialize
		@free_at = 0
	end

	def process(time, step)
		@free_at = time + step.duration
		step.process(time)
	end

	def free?(time)
		free_at <= time
	end
end

$workers=Array.new(5) { Worker.new }
$steps_completed=[]
$processing_steps={}

def available_steps(time)
	$rules.reject { |id, step| step.processing?(time) }
		  .select { |id, step| step.parent_steps.all? { |parent| parent.completed?(time) } }
		  .values
		  .sort_by { |step| step.id }
end

def uncompleted_steps(time)
	$rules.reject { |id, step| step.completed?(time) }
end

time = 0
binding.pry
while !(uncompleted_steps(time).empty?) do
	# Get list of free workers at time
	free_workers = $workers.select { |worker| worker.free?(time) }

	# Get list of available next steps
	available_steps(time).zip(free_workers).each do |step, worker|
		unless worker.nil?
			worker.process(time, step)
		end
	end

	# puts "At time #{time} - uncompleted steps: #{uncompleted_steps(time).keys}"

	time += 1
end

puts "Final time is #{time}"