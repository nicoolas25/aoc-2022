positions = ARGF.each_line.with_object([1]) do |line, positions_|
  case line.split
  in ["addx", number]
    positions_ << positions_.last << positions_.last + number.to_i
  in ["noop"]
    positions_ << positions_.last
  else
    raise
  end
end

# Part 1

cycles = [20, 60, 100, 140, 180, 220]
puts positions
  .each.with_index(1)
  .filter_map { _1 * _2 if cycles.include?(_2) }
  .sum

# Part 2

positions
  .each_slice(40)
  .map { |line|
    line.map.with_index { |p, crt_position|
      (p - crt_position).abs <= 1 ? "#" : " "
    }
  }
  .each { puts _1.join }
