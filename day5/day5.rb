lines = ARGF.each_line.map(&:chomp).to_a

class Stack
  attr_reader :items

  def initialize(items)
    @items = items
  end

  # Part 1
  def move_n_to(n, other_stack)
    n.times { other_stack.items.unshift(@items.shift) }
  end

  # Part 2
  def move_n_at_once_to(n, other_stack)
    other_stack.items.unshift(*@items.shift(n))
  end

  def top
    @items.first
  end
end

# Parse the stack, knowing the size of the input
stacks = lines[0...8]
  .map { _1.each_char.to_a }
  .transpose
  .drop(1)
  .each_slice(4)
  .map { |l| Stack.new(l.first.drop_while { _1.strip.empty? }) }

lines[10..].each do |line|
  count, source, destination = line.scan(/\d+/).map(&:to_i)
  stacks[source - 1].move_n_at_once_to(count, stacks[destination - 1])
end

puts stacks.map(&:top).join
