OPERATORS = %w[+ - * /].freeze

Item = Struct.new(
  :id,
  :worry_level
)

Monkey = Struct.new(
  :name,
  :items,
  :inspection_op,
  :divisible_by,
  :routing_fn,
  :inspection_counter
)

def Monkey.parse(*args)
  name, items, operation, test, if_true, if_false = args
  name = name[7]
  items = items.scan(/\d+/).map.with_index do |worry_level, i|
    Item.new("#{name}_#{i}", worry_level.to_i)
  end
  inspection_op =
    case operation[23..].split
    in [operator, "old"] if OPERATORS.include?(operator)
      -> { _1.worry_level.public_send(operator, _1.worry_level) }
    in [operator, operand] if OPERATORS.include?(operator)
      -> { _1.worry_level.public_send(operator, operand.to_i) }
    in any
      raise "Can't handle #{any}"
    end
  divisible_by = test.scan(/\d+/).first.to_i
  routing_fn = -> {
    (_1.worry_level % divisible_by).zero? ? if_true[29] : if_false[30]
  }
  Monkey.new(
    name,
    items,
    inspection_op,
    divisible_by,
    routing_fn,
    0
  )
end

monkeys_by_name = ARGF
  .each_line
  .map(&:chomp)
  .reject(&:empty?)
  .each_slice(6)
  .map { Monkey.parse(*_1) }
  .map { [_1.name, _1] }
  .to_h

lcm = monkeys_by_name.values.map(&:divisible_by).reduce { _1.lcm(_2) }

10_000.times do
  monkeys_by_name.each_value do |monkey|
    monkey.items.size.times do
      item = monkey.items.shift
      item.worry_level = monkey.inspection_op.call(item) % lcm
      monkeys_by_name.fetch(monkey.routing_fn.call(item)).items << item
      monkey.inspection_counter += 1
    end
  end
end

top1, top2 = monkeys_by_name.values.map(&:inspection_counter).sort.last(2)
puts top1 * top2
