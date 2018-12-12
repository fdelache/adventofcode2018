

class Puzzle9
	attr_reader :players_count
	attr_reader :last_marble

	def initialize(players_count, last_marble)
		@players_count = players_count
		@last_marble = last_marble
	end

	def high_score
		players_score = Hash.new(0)
		current_node = Node.new(0)
		current_node.next=current_node
		current_player = 1

		(1..last_marble).each do |marble|
			if (marble % 23) != 0
				marble_node = Node.new(marble)
				new_next = current_node.next.next
				current_node.next.next=marble_node
				marble_node.next=new_next
				current_node = marble_node
			else
				players_score[current_player] += marble
				to_remove = current_node.prev.prev.prev.prev.prev.prev.prev
				to_remove.prev.next=to_remove.next
				players_score[current_player] += to_remove.data

				current_node = to_remove.next
			end

			current_player = (current_player % players_count) + 1
		end

		players_score.max_by { |k,v| v }.last
	end

	def inspect
		"#{players_count} players; last marble is worth #{last_marble} points: high score is #{high_score}"
	end
end

class Node
	attr_reader :data, :prev, :next

	def initialize(data)
		@data = data
		@prev = nil
		@next = nil
	end

	def next=(node)
		@next = node
		node.prev=self
	end

	def prev=(node)
		@prev = node
	end
end


p Puzzle9.new(9, 25)
p Puzzle9.new(10, 1618)
p Puzzle9.new(13, 7999)
p Puzzle9.new(17, 1104)
p Puzzle9.new(21, 6111)
p Puzzle9.new(30, 5807)

p Puzzle9.new(493, 71863)
p Puzzle9.new(493, 7186300)