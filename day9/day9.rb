require "set"

Position = Struct.new(:i, :j) do
  def to(direction)
    di, dj = direction
    Position.new(i + di, j + dj)
  end

  def follow(other_position)
    di = other_position.i - i
    dj = other_position.j - j
    to([di.clamp(-1, 1), dj.clamp(-1, 1)])
  end
end

Rope = Struct.new(:positions) do
  def move(direction)
    positions[0] = positions[0].to(direction)
    (1...positions.size).each do |i|
      break unless is_too_far?(i)

      positions[i] = positions[i].follow(positions[i - 1])
    end
  end

  def tail
    positions.last
  end

  private

  def is_too_far?(i)
    p1, p2 = positions.slice(i - 1, 2)
    (p1.i - p2.i).abs > 1 || (p1.j - p2.j).abs > 1
  end
end

DIRECTIONS = {
  "R" => [ 1,  0],
  "L" => [-1,  0],
  "U" => [ 0, -1],
  "D" => [ 0,  1],
}

N = 10

zero = Position.new(0, 0)
rope = Rope.new([zero] * N)
tail_visited_positions = Set.new([rope.tail])

ARGF
  .each_line
  .map(&:chomp)
  .map(&:split)
  .each do |(d, n)|
    direction = DIRECTIONS.fetch(d)
    n.to_i.times do
      rope.move(direction)
      tail_visited_positions << rope.tail
    end
  end

puts tail_visited_positions.size
