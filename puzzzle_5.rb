require 'pry-byebug'

data = File.readlines('data/day_5_input').first

def process_string(data)
	data.each_char.reduce("") do |memo, c|
		# puts "memo: #{memo} - char: #{c}"
		if memo[-1] == c.swapcase
			memo.chop
		else
			memo + c
		end
	end
end

puts "Answer part 1: #{process_string(data).length}"

puts "data length: #{data.length}"
result_hash={}
("a".."z").each do |char_to_remove|
	# puts "For char #{char_to_remove} - stripped data length: #{stripped_data.length}"
	stripped_data = data.gsub(/#{char_to_remove}/i,"")
	result_hash[char_to_remove]=process_string(stripped_data).length
end

puts "Answer part 2: #{result_hash.min_by { |k,v| v }}"

