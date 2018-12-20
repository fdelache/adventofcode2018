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

class Map
  attr_reader :map
  attr_reader :units
  attr_reader :rounds

  def parse(filepath)
    Map.new(File.new(filepath).readlines.to_a)
  end

  def initialize(input)
    @map = {}
    @units = []
    input.each_with_index do |line, y|
      line.chomp.each_char.each_with_index do |c, x|
        @map[[x,y]] = c
        @units.push(Unit.new(c, x, y, self)) if %w[E G].include?(c)
      end
    end
  end

  def round
    units.sort.each do |unit|
      unit.round(self) if unit.alive?
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

  def adjacent_free_position(target)
    x = target.x
    y = target.y
    map.select { |position, state| target.adjacent_position?(position) }
       .reject { |position, state| state == '#' }
       .keys
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
end

class Unit
  attr_reader :x, :y, :type, :hit_points, :map

  def initialize(type, x, y, map)
    @type = type
    @x = x
    @y = y
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

    @x, @y = next_move
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
    !map.adjacent_free_positions(target).empty?
  end

  def reachable(target)
    # TODO - Check if there is a path
    true
  end

  def distance(target)
    x2 = target.x
    y2 = target.y

    (x - x2).abs + (y - y2).abs
  end

  def adjacent_position?(position)
    other_x, other_y = position

    (x - 1 == other_x && y == other_y) ||
      ((x + 1) == other_x && y == other_y) ||
      (x == other_x && (y - 1) == other_y) ||
      (x == other_x && (y + 1) == other_y)
  end

  def alive?
    hit_points > 0
  end

  def <=>(other)
    a = y <=> other.y
    a.zero? ? x <=> other.x : a
  end
end
