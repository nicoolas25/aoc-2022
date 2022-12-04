totals = ARGF
  .each_line
  .map(&:chomp)
  .chunk(&:empty?)
  .filter { |is_empty, _| !is_empty }
  .map { |_, numbers| numbers.map(&:to_i).sum }

puts totals.max
puts totals.sort.last(3).sum
