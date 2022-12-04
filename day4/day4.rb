total = ARGF
  .each_line
  .map(&:chomp)
  .flat_map { |line| line.split(",") }
  .map { |interval| Range.new(*interval.split("-").map(&:to_i)) }
  .each_slice(2)
  # .filter { |r1, r2| r1.cover?(r2) || r2.cover?(r1) }  # Part 1
  .filter { |r1, r2| r1.include?(r2.begin) || r1.include?(r2.end) || r2.include?(r1.begin) || r2.include?(r1.end) }
  .size

puts total
