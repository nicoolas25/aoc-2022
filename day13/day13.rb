def qualify(left, right)
  if left.nil?
    :right_order
  elsif left.is_a?(Integer) && right.is_a?(Integer)
    if left < right
      :right_order
    elsif left > right
      :wrong_order
    else
      :continue
    end
  elsif left.is_a?(Array) && right.is_a?(Array)
    padding = [nil] * (right.size - left.size).clamp(0, right.size)
    (left + padding).zip(right).each do |l, r|
      case qualify(l, r)
      when :continue then next
      when :right_order then return :right_order
      when :wrong_order then return :wrong_order
      end
    end
    :continue
  elsif left.is_a?(Integer) && right.is_a?(Array)
    qualify([left], right)
  elsif left.is_a?(Array) && right.is_a?(Integer)
    qualify(left, [right])
  else
    :wrong_order
  end
end


pairs = ARGF.read.split("\n\n")
  .map { |lines| lines.split.map { |line| eval line } }

# Part 1
puts pairs
  .filter_map.with_index(1) { |(a1, a2), i| i if qualify(a1, a2) == :right_order }
  .sum

# Part 2
dividers = [[[2]], [[6]]]
puts pairs.flatten(1).+(dividers)
  .sort { |a1, a2| qualify(a1, a2) == :right_order ? -1 : 1 }
  .each.with_index(1)
  .filter_map { |l, i| i if dividers.include?(l) }
  .reduce(&:*)
