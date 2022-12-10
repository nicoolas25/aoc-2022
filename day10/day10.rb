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

cycles_to_look_at.last.times do
  simulation.receive(instructions.shift) if simulation.can_receive_next_instruction?

  if cycles_to_look_at.include?(simulation.cycle_count)
    total_intensity += simulation.position * simulation.cycle_count
  end

  simulation.tick!
end

puts total_intensity

# Part 2

COL_COUNT = 40
ROW_COUNT = 6

pixels = []
simulation = Simulation.new
instructions = original_instructions.dup

def pixel_at(crt_position, simulation)
  sprite_range = Range.new(simulation.position - 1, simulation.position + 1)
  sprite_range.cover?(crt_position % COL_COUNT) ? "#" : "."
end

(ROW_COUNT * COL_COUNT).times do |crt_position|
  simulation.receive(instructions.shift) if simulation.can_receive_next_instruction?
  pixels << pixel_at(crt_position, simulation)
  simulation.tick!
end

pixels.each_slice(COL_COUNT) { puts _1.join }
