require "set"

Sensor = Struct.new(:position, :closest_beacon_position) do
  def range
    @range ||= position.distance(closest_beacon_position)
  end

  def x_range_on(y)
    dx = range - (position.y - y).abs
    dx.positive? ? Range.new(position.x - dx, position.x + dx) : nil
  end
end

Position = Struct.new(:x, :y) do
  def distance(other)
    (x - other.x).abs + (y - other.y).abs
  end
end

ScanValue = Struct.new(:in_range, :x_range)

def scan(y, sensors, x_range)
  return to_enum(__method__, y, sensors, x_range).lazy unless block_given?

  x = x_range.begin
  ranges = sensors.filter_map { _1.x_range_on(y) }
  while x <= x_range.end
    if (range = ranges.find { _1.cover?(x) })
      yield ScanValue.new(true, Range.new(x, range.end))
      x = range.end + 1
    elsif (next_x_in_ranges = ranges.filter_map { _1.begin if _1.begin > x }.min)
      yield ScanValue.new(false, Range.new(x, next_x_in_ranges - 1))
      x = next_x_in_ranges
    else
      yield ScanValue.new(false, Range.new(x, x_range.end))
      break
    end
  end
end

sensors = ARGF.each_line.map do |line|
  matches = line.match(/Sensor at x=(?<sx>-?\d+), y=(?<sy>-?\d+): closest beacon is at x=(?<bx>-?\d+), y=(?<by>-?\d+)/)
  sx, sy, bx, by = matches.values_at(:sx, :sy, :bx, :by).map(&:to_i)
  Sensor.new(Position.new(sx, sy), Position.new(bx, by))
end

# Part 1

def part_1(sensors)
  y = 2_000_000
  sensors_impacting_y = sensors.filter_map { _1.x_range_on(y) }
  min_x = sensors_impacting_y.map(&:begin).min - 1
  max_x = sensors_impacting_y.map(&:end).max + 1

  count = scan(y, sensors, min_x..max_x)
    .filter_map { _1.x_range.end - _1.x_range.begin + 1 if _1.in_range }
    .sum

  count - sensors.filter_map { _1.closest_beacon_position.x if _1.closest_beacon_position.y == y }.uniq.size
end

puts part_1(sensors)

# Part 2

def part_2(sensors)
  0.upto(4_000_000) do |y|
    x = scan(y, sensors, 0..4_000_000)
      .filter_map { _1.x_range.begin unless _1.in_range }
      .first

    return x * 4_000_000 + y if x
  end
end

puts part_2(sensors)
