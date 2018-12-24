require 'pry-byebug'

class Opcode
	def type
		self.class.to_s
	end
end

class Addr < Opcode
	def process(registers, a, b, c)
		registers = registers.dup
		registers[c] = registers[a] + registers[b]
		registers
	end
end

class Addi < Opcode
	def process(registers, a, b, c)
		registers = registers.dup
		registers[c] = registers[a] + b
		registers
	end
end

class Mulr < Opcode
	def process(registers, a, b, c)
		registers = registers.dup
		registers[c] = registers[a] * registers[b]
		registers
	end
end

class Muli < Opcode
	def process(registers, a, b, c)
		registers = registers.dup
		registers[c] = registers[a] * b
		registers
	end
end

class Banr < Opcode
	def process(registers, a, b, c)
		registers = registers.dup
		registers[c] = registers[a] & registers[b]
		registers
	end
end

class Bani < Opcode
	def process(registers, a, b, c)
		registers = registers.dup
		registers[c] = registers[a] & b
		registers
	end
end

class Borr < Opcode
	def process(registers, a, b, c)
		registers = registers.dup
		registers[c] = registers[a] | registers[b]
		registers
	end
end

class Bori < Opcode
	def process(registers, a, b, c)
		registers = registers.dup
		registers[c] = registers[a] | b
		registers
	end
end

class Setr < Opcode
	def process(registers, a, b, c)
		registers = registers.dup
		registers[c] = registers[a]
		registers
	end
end

class Seti < Opcode
	def process(registers, a, b, c)
		registers = registers.dup
		registers[c] = a
		registers
	end
end

class Gtir < Opcode
	def process(registers, a, b, c)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if a > registers[b]
		new_registers
	end
end

class Gtri < Opcode
	def process(registers, a, b, c)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if registers[a] > b
		new_registers
	end
end

class Gtrr < Opcode
	def process(registers, a, b, c)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if registers[a] > registers[b]
		new_registers
	end
end

class Eqir < Opcode
	def process(registers, a, b, c)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if a == registers[b]
		new_registers
	end
end

class Eqri < Opcode
	def process(registers, a, b, c)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if registers[a] == b
		new_registers
	end
end

class Eqrr < Opcode
	def process(registers, a, b, c)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if registers[a] == registers[b]
		new_registers
	end
end

opcodes = [Addr.new, Addi.new, Mulr.new, Muli.new, Banr.new, Bani.new, Borr.new, Bori.new, Setr.new, Seti.new, Gtir.new, Gtri.new, Gtrr.new, Eqir.new, Eqri.new, Eqrr.new]


SAMPLE=<<~EOS
Before: [3, 2, 1, 1]
9 2 1 2
After:  [3, 2, 2, 1]


EOS

data = File.readlines('./data/day_16_input')
# data=SAMPLE.split("\n")

count = 0

opcodes_ids=Array.new(16)
resolved_opcodes = Array.new(16)

loop do
	break if data[0].length < 2

	before = data.shift.match(/Before:\s+\[(\d+), (\d+), (\d+), (\d+)\]/)[1..4].map(&:to_i)
	opcode, a, b, c = data.shift.match(/(\d+) (\d+) (\d+) (\d+)/)[1..4].map(&:to_i)
	after = data.shift.match(/After:\s+\[(\d+), (\d+), (\d+), (\d+)\]/)[1..4].map(&:to_i)
	data.shift

	matching_opcodes = opcodes.select do |opcode|
		opcode.process(before, a, b, c) == after
	end

	opcodes_ids[opcode] = matching_opcodes if opcodes_ids[opcode].nil?
	opcodes_ids[opcode] = opcodes_ids[opcode] & matching_opcodes

	if opcodes_ids[opcode].length == 1
		resolved_opcodes[opcode] = opcodes_ids[opcode].first
		opcodes = opcodes - resolved_opcodes
		opcodes_ids = opcodes_ids.map do |op|
			op -= resolved_opcodes unless op.nil?
		end
	end
end

puts "Found opcodes:"
resolved_opcodes.each_with_index do |op, id|
	puts "id: #{id} - Opcode: #{op}"
end

binding.pry
registers=[0,0,0,0]
loop do
	line = data.shift
	break if line.nil?
	
	next if line.length < 2

	opcode, a, b, c = line.match(/(\d+) (\d+) (\d+) (\d+)/)[1..4].map(&:to_i)
	registers = resolved_opcodes[opcode].process(registers, a, b, c)
end

puts "Register 0: #{registers[0]}"