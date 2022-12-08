require "set"

Tree = Struct.new(:i, :j, :size)

MAX_SIZE = 9

def visible_from_the_outside(line)
  line.each.with_object([]) do |t, trees|
    trees << t if trees.empty? || t.size > trees.last.size

    break trees if trees.last.size >= MAX_SIZE
  end
end

def visible_from_the_tree_house_count(line, max)
  line.reduce(0) do |count, t|
    break count + 1 if t.size >= max

    count + 1
  end
end

def scenic_scores(line)
  line.each.with_index.with_object({}) do |(tree, i), scores|
    scores[tree] = visible_from_the_tree_house_count(
      line[(i + 1)..],
      tree.size,
    )
  end
end

forest = ARGF
  .each_line
  .map(&:chomp)
  .each.with_index
  .map { |line, i|
    line.each_char.map.with_index { |size, j|
      Tree.new(i, j, size.to_i)
    }
  }

lines_of_sight = forest + forest.transpose

# Part 1
trees = lines_of_sight.reduce(Set.new) do |trees_, line_of_sight|
  trees_ |
    visible_from_the_outside(line_of_sight) |
    visible_from_the_outside(line_of_sight.reverse)
end

puts trees.size

# Part 2
scores = lines_of_sight.reduce({}) do |scores_, line_of_sight|
  scores_.merge(
    scenic_scores(line_of_sight),
    scenic_scores(line_of_sight.reverse),
  ) { |_, s1, s2| s1 * s2 }
end

puts scores.values.max
