PRIORITIES = [*('a'..'z'), *('A'..'Z')].each.with_index(1).to_h

lines = ARGF
  .each_line
  .map(&:chomp)

# Part 1
total = lines
  .map { |line| [line[...(line.size / 2)], line[(line.size / 2)..]] }
  .map { |c1, c2| c1.each_char.find { |c| c2.include?(c) } }
  .map { |letter| PRIORITIES.fetch(letter) }
  .sum

puts total

total = lines
  .each_slice(3)
  .map { |r1, r2, r3| r1.each_char.find { |c| r2.include?(c) && r3.include?(c) } }
  .map { |letter| PRIORITIES.fetch(letter) }
  .sum

puts total
