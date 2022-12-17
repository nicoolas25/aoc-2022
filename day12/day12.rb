require "set"

State = Struct.new(:i, :j, :height, :is_exit, :is_start, :is_seen) do
  def reacheable_positions_in(map)
    [].tap do |a|
      a << map[i + 1][j] if i + 1 < map.size
      a << map[i - 1][j] if i > 0
      a << map[i][j + 1] if j + 1 < map[0].size
      a << map[i][j - 1] if j > 0
    end.select { height - 1 <= _1.height }
  end
end

map = ARGF.each_line.map(&:chomp).map.with_index do |line, i|
  line.each_char.map.with_index do |char, j|
    State.new(i, j, (char == "E" ? "z" : char == "S" ? "a" : char).ord, char == "E", char == "S", false)
  end
end

searched_position = map.flatten.find(&:is_start)
next_positions = [map.flatten.find(&:is_exit)]
tick = 0

part_1_condition = -> { !searched_position.is_seen }

a_positions = map.flatten.select { _1.height == "a".ord }
part_2_condition = -> { !a_positions.any?(&:is_seen) }

while part_2_condition.call()
  next_positions = next_positions.flat_map do |position|
    position
      .reacheable_positions_in(map)
      .reject { _1.is_seen }
      .each { _1.is_seen = true }
  end
  tick += 1
end

puts tick
