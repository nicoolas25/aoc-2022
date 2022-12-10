Instruction = Struct.new(:duration, :position_diff)

def simulation_steps_for(instructions)
  position = 1
  Enumerator.new do |steps|
    instructions.each do |instruction|
      instruction.duration.times { steps << position }
      position += instruction.position_diff
    end
    steps << position
  end.lazy
end

instructions = ARGF.each_line.map do |line|
  case line.chomp.split
  in ["addx", number]
    Instruction.new(2, number.to_i)
  in ["noop"]
    Instruction.new(1, 0)
  else
    raise
  end
end

# Part 1

steps = simulation_steps_for(instructions)
cycles_to_look_at = [20, 60, 100, 140, 180, 220]

total_intensity = steps
  .with_index(1)
  .filter_map { _1 * _2 if cycles_to_look_at.include?(_2) }
  .sum

puts total_intensity

# Part 2

steps = simulation_steps_for(instructions)
6.times do
  40.times do |crt_position|
    position = steps.next
    range = Range.new(position - 1, position + 1)
    print(range.cover?(crt_position) ? "#" : " ")
  end
  puts("")
end
