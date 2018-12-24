require 'pry-byebug'

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

class Cell
  attr_reader :type

  def initialize(type)
    @type = type
  end

  def free?
    type == '.'
  end

  def unit?
    false
  end

  def render
    type
  end
end

class Unit < Cell
  attr_reader :map
  attr_accessor :position, :hit_points

  def initialize(type, position, map)
    super(type)
    @position = position
    @map = map
    @hit_points = 200
  end

  def attack_points
    type == 'G' ? 3 : map.elves_attack
  end

  def hit_points
    @hit_points < 0 ? 0 : @hit_points
  end

  def render
    alive? ? super : '.'
  end

  def free?
    !alive?
  end

  def unit?
    true
  end

  def round
    move
    attack
  end

  def move
    return if next_to_target?

    # map.render

    distances = compute_distances
    path = shortest_path(distances)

    return if path.nil?
    next_position = path.first

    # print_distances(distances)

    map.move(self, next_position)
  end

  def next_to_target?
    map.unit_surround_position(position)
      .any? do |position|
        map.fetch_cell(position)&.type != self.type
    end
  end

  def compute_distances
    distances = Array.new(map.map.length) { Array.new(map.map[0].length) }

    positions_to_process = [self.position]
    x, y = self.position
    distance = 0
    distances[y][x] = distance

    loop do
      position = positions_to_process.shift
      x, y = position
      distance = distances[y][x]

      map.free_surround_positions(position).each do |position|
        x, y = position
        if distances[y][x].nil?
          distances[y][x] = distance + 1
          positions_to_process.push(position)
        end
      end

      break if positions_to_process.empty?
    end

    distances
  end

  def print_distances(distances)
    distances.each do |row|
      row.each do |distance|
        print "#{distance.nil? ? '#' : distance} "
      end
      puts ''
    end
  end

  def shortest_path(distances)
    target_positions = target_units.flat_map do |target|
      map.free_surround_positions(target.position)
    end

    return nil if target_positions.empty?

    # binding.pry
    closest_positions = target_positions.reject do |position|
      x, y = position
      distances[y][x].nil?
    end.mins_by do |position|
      x, y = position
      distances[y][x]
    end

    closest_position = closest_positions.mins_by { |position| position[1] }
      .mins_by { |position| position[0] }
      .first

    return nil if closest_position.nil?

    paths = compute_paths_to(closest_position, distances)

    paths.mins_by { |path| path.first[1] }
      .mins_by { |path| path.first[0] }
      .first
  end

  def compute_paths_to(position, distances)
    x, y = position
    current_distance = distances[y][x]

    return [[position]] if current_distance == 1

    free_cells = map.free_surround_positions(position)
    parent_cells = free_cells.reject do |position|
      x, y = position
      distances[y][x].nil?
    end.mins_by do |position|
      x, y = position
      distances[y][x]
    end

    parent_cells.flat_map { |cell| compute_paths_to(cell, distances) }
      .map { |path| path.push(position) }
  end

  def target_units
    map.units.select { |unit| unit.type != self.type }.select(&:alive?)
  end

  def attack
    return unless next_to_target?

    target = map.unit_surround_position(position)
      .map { |position| map.fetch_cell(position) }
      .select { |unit| unit.type != self.type }
      .mins_by { |unit| unit.hit_points }
      .sort
      .first

    target.hit_points -= attack_points
  end

  def distance(other_position)
    x1, y1 = position
    x2, y2 = other_position

    (x1 - x2).abs + (y1 - y2).abs
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
  attr_reader :rounds, :input
  attr_accessor :elves_attack

  FREE_CELL = Cell.new('.')
  WALL_CELL = Cell.new('#')

  def parse(filepath)
    Map.new(File.new(filepath).readlines.to_a)
  end

  def initialize(input)
    @input = input
    @rounds = 0
    @map = Array.new(input.length) { Array.new }
    @units = []
    @elves_attack = 3

    input.each_with_index do |line, y|
      line.chomp.each_char.each_with_index do |c, x|
        cell = nil
        if %w[E G].include?(c)
          cell = Unit.new(c, [x, y], self)
          @units.push(cell)
        elsif c == '.'
          cell = FREE_CELL
        else
          cell = WALL_CELL
        end
        @map[y][x] = cell
      end
    end
  end

  def round
    sorted_units = units.sort.select { |unit| unit.alive? }
    sorted_units.each do |unit|
      unit.round if unit.alive?

      @rounds += 1 if sorted_units.last == unit

      return if no_targets_remaining
    end
  end

  def part1
    loop do
      render

      round

      break if no_targets_remaining
    end

    render
    render_units
    puts "Part1: #{rounds * units_remaining_points}"
  end

  def round_til_first_elf_death_or_win
    loop do
      round

      return false if one_elf_dies
      break if no_targets_remaining
    end

    true
  end

  def part2
    trial = nil

    (4..Float::INFINITY).each do |elf_attack|
      trial = Map.new(input)
      trial.elves_attack = elf_attack

      puts "Trying with elf attack: #{elf_attack}"

      break if trial.round_til_first_elf_death_or_win
    end

    trial.render
    trial.render_units
    puts "Part2: #{trial.rounds * trial.units_remaining_points}"
  end

  def one_elf_dies
    units.select { |unit| unit.type == 'E' }
      .any? { |elf| !elf.alive? }
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

  def fetch_cell(position)
    map.fetch(position[1], nil)&.fetch(position[0], nil)
  end

  def free_cell(position)
    fetch_cell(position)&.free?
  end

  def unit?(position)
    fetch_cell(position)&.unit?
  end

  def free_surround_positions(position)
    [[-1, 0], [0, 1], [1, 0], [0, -1]].map { |delta| [position[0] + delta[0], position[1] + delta[1]] }
      .select { |position| free_cell(position) }
  end

  def unit_surround_position(position)
    [[-1, 0], [0, 1], [1, 0], [0, -1]].map { |delta| [position[0] + delta[0], position[1] + delta[1]] }
      .select { |position| unit?(position) }
      .select { |position| fetch_cell(position).alive? }
  end

  def move(unit, new_position)
    raise "Moved by #{unit.distance(new_position)}" if unit.distance(new_position) != 1

    x, y = unit.position
    map[y][x] = FREE_CELL

    unit.position = new_position
    x, y = unit.position
    map[y][x] = unit
  end

  def render
    puts "Map at round #{rounds}:"
    map.each do |row|
      row.each do |cell|
        print "#{cell.render}"
      end
      puts ''
    end
  end

  def render_units
    units.select { |unit| unit.alive? }
      .each { |unit| puts "#{unit.type}(#{unit.hit_points})"}
  end
end

SAMPLE0 = <<-EOS.split(/\n/)
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######
EOS

SAMPLE1 = <<-EOS.split(/\n/)
#######
#G..#E#
#E#E.E#
#G.##.#
#...#E#
#...E.#
#######
EOS

SAMPLE2 = <<-EOS.split(/\n/)
#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######
EOS

SAMPLE3 = <<-EOS.split(/\n/)
#######
#E.G#.#
#.#G..#
#G.#.G#
#G..#.#
#...E.#
#######
EOS

SAMPLE4 = <<-EOS.split(/\n/)
#######
#.E...#
#.#..G#
#.###.#
#E#G#G#
#...#G#
#######
EOS

SAMPLE5 = <<-EOS.split(/\n/)
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########
EOS

data = File.readlines('./data/day_15_input')

# binding.pry
Map.new(data).part2
