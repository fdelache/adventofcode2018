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
		instruction_pointer = 3
		registers = Array.new(6) { 0 }
		registers = [2637831, 3, 10551319, 10551320, 0, 2637830]

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
end


SAMPLE=<<~EOS
#ip 0
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5
EOS

program = Program.parse('./data/day_19_input')
# program = Program.new(SAMPLE.split("\n"))
program.execute_program
