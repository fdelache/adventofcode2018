module Enumerable
  def mins_by
    minimums = []
    min_value = nil
    self.each do |e|
      value = yield e

      if minimums.empty?
        minimums << e
        min_value = value
      else
        if value < min_value
          minimums.clear
          minimums << e
          min_value = value
        elsif value == min_value
          minimums << e
        end
      end
    end

    minimums
  end
end

class Node
  attr_reader :position, :type

  def initialize(type, position)
    @type = type
    @position = position
  end
end

class Unit < Node
  attr_reader :hit_points, :map

  def initialize(type, position, map)
    super(type, position)
    @map = map
    @hit_points = 200
  end

  def round
    move
    attack
  end

  def move
    selected_target = target_units.select { |t| in_range(t) }
      .select { |t| reachable(t) }
      .mins_by { |t| distance(t) }
      .sort
      .first

    next_move = get_path(selected_target).first

    @position = next_move
  end

  def target_units
    map.units.select { |unit| unit.type != self.type }.select(&:alive?)
  end

  def attack

  end

  def get_path(target)
    # TODO - get shortest path here.
    # Return array of positions
    []
  end

  def in_range(target)
    [[-1, 0], [0, 1], [1, 0], [0, -1]].any? do |delta|
      new_position = [position[0] + delta[0], position[1] + delta[1]]
      map.fetch_node(new_position)&.type == '.'
    end
  end

  def reachable(target)
    # TODO - Check if there is a path
    true
  end

  def distance(target)
    x1, y1 = position
    x2, y2 = target.position

    (x1 - x2).abs + (y1 - y2).abs
  end

  def adjacent_position?(other_position)
    x, y = position
    other_x, other_y = other_position

    (x - 1 == other_x && y == other_y) ||
      ((x + 1) == other_x && y == other_y) ||
      (x == other_x && (y - 1) == other_y) ||
      (x == other_x && (y + 1) == other_y)
  end

  def alive?
    hit_points > 0
  end

  def <=>(other)
    a = position[1] <=> other.position[1]
    a.zero? ? position[0] <=> other.position[0] : a
  end
end

class Map
  attr_reader :map
  attr_reader :units
  attr_reader :rounds

  def parse(filepath)
    Map.new(File.new(filepath).readlines.to_a)
  end

  def initialize(input)
    @map = Array.new(input.length) { Array.new }
    @units = []
    input.each_with_index do |line, y|
      line.chomp.each_char.each_with_index do |c, x|
        node = nil
        if %w[E G].include?(c)
          node = Unit.new(c, [x, y], self)
          @units.push(node)
        else
          node = Node.new(c, [x, y])
        end
        @map[y][x] = node
      end
    end
  end

  def round
    units.sort.each do |unit|
      unit.round if unit.alive?
    end

    @rounds += 1
  end

  def part1
    loop do
      round

      break if no_targets_remaining
    end

    puts "Part1: #{rounds * units_remaining_points}"
  end

  def units_remaining_points
    units.reduce(0) { |sum, unit| sum += unit.hit_points }
  end

  def no_targets_remaining
    alive_units = units.select(&:alive?)
    all_goblins = alive_units.all? { |unit| unit.type == 'G' }
    all_elves = alive_units.all? { |unit| unit.type == 'E' }

    all_goblins || all_elves
  end

  def fetch_node(position)
    map.fetch(position[1], nil)&.fetch(position[0], nil)
  end

  def render
    map.each do |row|
      row.each do |node|
        print "#{node.type}"
      end
      puts ''
    end
  end
end

SAMPLE1=<<-EOS.split(/\n/)
#########
#G..G..G#
#.......#
#.......#
#G..E..G#
#.......#
#.......#
#G..G..G#
#########
EOS

Map.new(SAMPLE1).render