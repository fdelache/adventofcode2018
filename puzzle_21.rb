require 'pry-byebug'

class Opcode
	attr_reader :a, :b, :c

	def initialize(a, b, c)
		@a = a
		@b = b
		@c = c
	end

	def type
		self.class.to_s
	end

	def inspect
		"#{type} - #{a} #{b} #{c}"
	end
end

class Addr < Opcode
	def process(registers)
		registers = registers.dup
		registers[c] = registers[a] + registers[b]
		registers
	end
end

class Addi < Opcode
	def process(registers)
		registers = registers.dup
		registers[c] = registers[a] + b
		registers
	end
end

class Mulr < Opcode
	def process(registers)
		registers = registers.dup
		registers[c] = registers[a] * registers[b]
		registers
	end
end

class Muli < Opcode
	def process(registers)
		registers = registers.dup
		registers[c] = registers[a] * b
		registers
	end
end

class Banr < Opcode
	def process(registers)
		registers = registers.dup
		registers[c] = registers[a] & registers[b]
		registers
	end
end

class Bani < Opcode
	def process(registers)
		registers = registers.dup
		registers[c] = registers[a] & b
		registers
	end
end

class Borr < Opcode
	def process(registers)
		registers = registers.dup
		registers[c] = registers[a] | registers[b]
		registers
	end
end

class Bori < Opcode
	def process(registers)
		registers = registers.dup
		registers[c] = registers[a] | b
		registers
	end
end

class Setr < Opcode
	def process(registers)
		registers = registers.dup
		registers[c] = registers[a]
		registers
	end
end

class Seti < Opcode
	def process(registers)
		registers = registers.dup
		registers[c] = a
		registers
	end
end

class Gtir < Opcode
	def process(registers)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if a > registers[b]
		new_registers
	end
end

class Gtri < Opcode
	def process(registers)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if registers[a] > b
		new_registers
	end
end

class Gtrr < Opcode
	def process(registers)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if registers[a] > registers[b]
		new_registers
	end
end

class Eqir < Opcode
	def process(registers)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if a == registers[b]
		new_registers
	end
end

class Eqri < Opcode
	def process(registers)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if registers[a] == b
		new_registers
	end
end

class Eqrr < Opcode
	def process(registers)
		new_registers = registers.dup
		new_registers[c] = 0
		new_registers[c] = 1 if registers[a] == registers[b]
		new_registers
	end
end

class Program
	attr_reader :ip_register
	attr_reader :instructions

	def self.parse(filepath)
		Program.new(File.readlines(filepath))
	end

	def initialize(lines)
		@instructions = []

		@ip_register = lines.shift.match(/#ip (\d+)/)[1].to_i
		lines.each do |line|
			opcode, a, b, c = line.match(/(\w+) (\d+) (\d+) (\d+)/)[1..4]
			@instructions.push(Object.const_get(opcode.capitalize).new(a.to_i, b.to_i, c.to_i))
		end
	end

	def execute_program
		instruction_pointer = 0
		registers = Array.new(6) { 0 }
		
		loop do
			break if (instruction_pointer < 0) || (instruction_pointer >= instructions.length)

			registers[ip_register] = instruction_pointer

			instruction = instructions[instruction_pointer]
			puts "Executing instruction #{instruction_pointer}: #{instruction.inspect} with registers #{registers}"
			gets
			registers = instruction.process(registers)

			instruction_pointer = registers[ip_register]
			instruction_pointer += 1
		end

		puts "Registers: #{registers}"
	end

	def execute_optimized_program
		exit_instruction = 28
		# Must put value of register 2 in register 0 when we reach instruction 28
		# Must attain instruction 16 (which jumps to instruction 28)

		r = Array.new(6) { 0 }
		# r[0] = 8797248	 # part 1 value
		r2_values = []

		r[5] = r[2] | 65536
		r[2] = 4843319
		loop do
			r[4] = r[5] & 255
			r[2] = r[4] + r[2]
			r[2] = r[2] & 16777215	# Keep only 24 first bits
			r[2] = r[2] * 65899
			r[2] = r[2] & 16777215	# Keep only 24 first bits
			if 256 > r[5]
				# Jump to ip 28
				if r2_values.include?(r[2])
					puts "Already seen r2: #{r[2]}"
					puts "Part2: #{r2_values[-1]}"
					break
				else
					r2_values.push(r[2])
				end

				# puts "r[2]: #{r[2]}"
				if r[2] == r[0]
					# This our exit point.
					break
				else
					r[5] = r[2] | 65536	# Set bit 17 to 1
					r[2] = 4843319
				end
			else
				r[5] = r[5] / 256
				# r[4] = 0
				# r[3] = 256

				# loop do
				# 	if r[3] > r[5]
				# 		# Jump to ip 26
				# 		r[5] = r[4]
				# 		# Jump to 8
				# 		break
				# 	else
				# 		r[4] += 1
				# 		r[3] = r[4] + 1
				# 		r[3] = r[3] * 256
				# 		# Jump to 18
				# 	end
				# end
			end
		end

		r
	end
end

program = Program.parse('./data/day_21_input')
# program = Program.new(SAMPLE.split("\n"))
# program.execute_program
# program.part2

puts "Registers are: #{program.execute_optimized_program}"
