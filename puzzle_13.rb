require 'pry-byebug'

class Map
  attr_reader :tracks
  attr_reader :carts
  attr_reader :tick

  def initialize(filepath)
    @carts = []
    @tracks = {}
    @tick = 0
    File.readlines(filepath).each_with_index do |line, y|
      line.each_char.each_with_index do |c, x|
        case c
        when '/'
          @tracks[[x,y]] = :turn_45
        when '-'
          @tracks[[x,y]] = :horizontal
        when '\\'
          @tracks[[x,y]] = :turn_135
        when '|'
          @tracks[[x,y]] = :vertical
        when '+'
          @tracks[[x,y]] = :cross
        when '<'
          @carts << Cart.new(x,y, :left)
          @tracks[[x,y]] = :horizontal
        when '^'
          @carts << Cart.new(x,y, :up)
          @tracks[[x,y]] = :vertical
        when '>'
          @carts << Cart.new(x,y, :right)
          @tracks[[x,y]] = :horizontal
        when 'v'
          @carts << Cart.new(x,y, :down)
          @tracks[[x,y]] = :vertical
        end
      end
    end
  end

  def ticks
    carts.each do |cart|
      cart.move(tracks)
      return true if collision?
    end

    @tick += 1
    false
  end

  def ticks_remove_collisions
    carts.each do |cart|
      cart.move(tracks)
      remove_collisions
    end

    @tick += 1
    carts.size == 1
  end

  def remove_collisions
    @carts = carts - collisions
  end

  def collisions
    carts - carts.uniq { |cart| [cart.x, cart.y] }
  end

  def collision?
    carts.uniq { |cart| [cart.x, cart.y] }.size != carts.size
  end
end

class Cart
  attr_reader :x, :y, :direction, :last_cross

  def initialize(x, y, direction)
    @x = x
    @y = y
    @direction = direction
    @last_cross = :right
  end

  def move(tracks)
    case direction
    when :up
      @y -= 1
      case tracks[[x,y]]
      when :turn_45
        @direction = :right
      when :turn_135
        @direction = :left
      when :cross
        case last_cross
        when :right
          @direction = :left
          @last_cross = :left
        when :left
          @last_cross = :straight
        when :straight
          @direction = :right
          @last_cross = :right
        end
      end
    when :down
      @y += 1
      case tracks[[x,y]]
      when :turn_45
        @direction = :left
      when :turn_135
        @direction = :right
      when :cross
        case last_cross
        when :right
          @direction = :right
          @last_cross = :left
        when :left
          @last_cross = :straight
        when :straight
          @direction = :left
          @last_cross = :right
        end
      end
    when :right
      @x += 1
      case tracks[[x,y]]
      when :turn_45
        @direction = :up
      when :turn_135
        @direction = :down
      when :cross
        case last_cross
        when :right
          @direction = :up
          @last_cross = :left
        when :left
          @last_cross = :straight
        when :straight
          @direction = :down
          @last_cross = :right
        end
      end
    when :left
      @x -= 1
      case tracks[[x,y]]
      when :turn_45
        @direction = :down
      when :turn_135
        @direction = :up
      when :cross
        case last_cross
        when :right
          @direction = :down
          @last_cross = :left
        when :left
          @last_cross = :straight
        when :straight
          @direction = :up
          @last_cross = :right
        end
      end
    end
  end
end

map = Map.new('./data/day_13_input')

loop do
  break if map.ticks_remove_collisions

  p map.carts
end

puts "Last cart at #{map.tick} is #{map.carts}"
