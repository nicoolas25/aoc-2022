Instruction = Struct.new(:duration, :position_diff)

class Simulation
  attr_reader :cycle_count, :position

  def initialize
    @position = 1
    @cycle_count = 1

    @last_instruction = nil
    @last_instruction_ends_on = 0
  end

  def receive(instruction)
    @last_instruction = instruction
    @last_instruction_ends_on = @cycle_count + instruction.duration
  end

  def can_receive_next_instruction?
    @last_instruction_ends_on <= @cycle_count
  end

  def tick!
    @cycle_count += 1
    @position += @last_instruction.position_diff if @last_instruction_ends_on == @cycle_count
  end
end

original_instructions = ARGF.each_line.map do |line|
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

total_intensity = 0
simulation = Simulation.new
instructions = original_instructions.dup
cycles_to_look_at = [20, 60, 100, 140, 180, 220]

loop do
  if simulation.can_receive_next_instruction?
    simulation.receive(instructions.shift)
  end

  simulation.tick!

  if cycles_to_look_at.include?(simulation.cycle_count)
    total_intensity += simulation.position * simulation.cycle_count
  end

  break if simulation.cycle_count > cycles_to_look_at.last
end

puts total_intensity

# Part 2

pixels = []
simulation = Simulation.new
instructions = original_instructions.dup

(6 * 40).times do |crt_position|
  break if instructions.empty?

  if simulation.can_receive_next_instruction?
    simulation.receive(instructions.shift)
  end

  if ((crt_position % 40) - simulation.position).abs <= 1
    pixels << "#"
  else
    pixels << "."
  end

  simulation.tick!
end

pixels.each_slice(40) { puts _1.join }
