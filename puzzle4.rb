require 'date'
require 'pry'

def getDate(line)
	DateTime.parse(line.match(/\[(.*)\]/)[1])
end

def getGuardId(line)
	matcher = line.match(/Guard #(\d+)/)
	if matcher
		matcher[1]
	else
		nil
	end
end

def fallAsleep(line)
	line.match(/falls asleep/)
end

def wakesUp(line)
	!!line.match(/wakes up/)
end

data = File.readlines('data/day_4_input')

sorted_data = data.sort do |a, b|
	date_a = getDate(a)
	date_b = getDate(b)
	date_a <=> date_b
end

current_guard_id = nil
asleep_minutes = nil
wakeup_minutes = nil

guard_minutes_count = {}
sorted_data.each do |line|
	current_guard_id = getGuardId(line) if getGuardId(line)
	asleep_minutes = getDate(line).minute if fallAsleep(line)
	wakeup_minutes = getDate(line).minute if wakesUp(line)

	if wakesUp(line)
		(asleep_minutes...wakeup_minutes).each do |minute|
			# binding.pry
			if !(guard_minutes_count.key?(current_guard_id))
				guard_minutes_count[current_guard_id] = Hash.new(0)
			end

			guard_minutes_count[current_guard_id][minute.to_s] += 1
		end
	end
end

puts "Guard minutes count: #{guard_minutes_count.map { |k,v| v.length }}"

guard_ids = guard_minutes_count.select { |k, v| v.length == 59 }
puts "most guard minutes: #{guard_ids.keys}"

guard_ids.each do |guard_id,v|
	most_minute = guard_minutes_count[guard_id].max_by { |k,v| v }
	puts "Guard #{guard_id} has #{most_minute} most minute"
end

puts "guard with most minutes"
# puts guard_minutes_count
guard_minutes_count.each do |guard_id,value|
	most_minutes = value.select { |k,v| v == value.values.max }
	puts "Guard #{guard_id} has #{most_minutes} most minute"
end
