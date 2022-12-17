require "set"

Position = Struct.new(:i, :j) do
  def to(other)
    return to_enum(__method__, other) unless block_given?

    di = (other.i - i).clamp(-1, 1)
    dj = (other.j - j).clamp(-1, 1)
    yield (current = self)
    yield (current = current.apply(di, dj)) while current != other
  end

  def apply(di, dj)
    Position.new(i + di, j + dj)
  end
end

def Position.parse(coordinates)
  Position.new(*coordinates.split(",").map(&:to_i).reverse)
end

occupied_positions = ARGF.each_line
  .map(&:chomp)
  .flat_map { _1.split(" -> ").map(&Position.method(:parse)).each_cons(2).to_a }
  .reduce(Set.new) { |set, (p1, p2)| set | p1.to(p2) }

walls = occupied_positions.size
max_i = occupied_positions.max_by(&:i).i
floor = max_i + 2
directions_to_try = [[1, 0], [1, -1], [1, 1]]

# Part 1: stop at the first grain of sand that fall beyond max_i
# goal_reached = ->(pos) { pos.i > max_i }

# Part 2: stop at the first grain of sand that comes to 0, 500
goal_reached = ->(pos) { pos.i == 0 && pos.j == 500 }

loop do
  sand = Position.new(0, 500)

  loop do
    next_position = directions_to_try.each.lazy
      .map { |di, dj| sand.apply(di, dj) }
      .filter { |pos| !occupied_positions.member?(pos) && pos.i != floor }
      .first
    sand = next_position || sand # Sand falls or it settles
    break if next_position.nil? || goal_reached[sand]
  end

  break if goal_reached[sand]

  occupied_positions << sand
end

# Part 1
# puts occupied_positions.size - walls

# Part 2
puts occupied_positions.size - walls + 1
