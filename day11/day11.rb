Monkey = Struct.new(:name, :items, :do_inspect, :multiple, :if_true, :if_false, :inspect_count) do
  def inspect_first_item!
    self.inspect_count += 1
    do_inspect.call(items.shift)
  end

  def successor_for(item)
    (item % multiple).zero? ? if_true : if_false
  end
end

def Monkey.parse(lines)
  matches = lines.match(Regexp.new(
    'Monkey (?<name>\d):' \
    '\s+Starting items: (?<items>\d+(, \d+)*)' \
    '\s+Operation: new = old (?<operator>[+*]) (?<operand>\d+|old)' \
    '\s+Test: divisible by (?<multiple>\d+)' \
    '\s+If true: throw to monkey (?<if_true>\d)' \
    '\s+If false: throw to monkey (?<if_false>\d)'
  ))
  name, if_true, if_false = matches.values_at(:name, :if_true, :if_false)
  items = matches[:items].split(", ").map(&:to_i)
  multiple = matches[:multiple].to_i
  do_inspect = case matches.values_at(:operator, :operand)
               in [op, "old"] then -> { _1.public_send(op, _1) }
               in [op, i] then -> { _1.public_send(op, i.to_i) }
               end
  Monkey.new(name, items, do_inspect, multiple, if_true, if_false, 0)
end

monkeys_by_name = ARGF
  .each_line
  .map(&:chomp)
  .reject(&:empty?)
  .each_slice(6)
  .map { Monkey.parse(_1.join("\n")) }
  .map { [_1.name, _1] }
  .to_h


lcm = monkeys_by_name.values.map(&:multiple).reduce { _1.lcm(_2) }

10_000.times do
  monkeys_by_name.each_value do |monkey|
    monkey.items.size.times do
      item = monkey.inspect_first_item! % lcm
      monkeys_by_name.fetch(monkey.successor_for(item)).items << item
    end
  end
end

top1, top2 = monkeys_by_name.values.map(&:inspect_count).sort.last(2)
puts top1 * top2
