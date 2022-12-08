module AOC
  File = Struct.new(:size)

  Directory = Struct.new(:items) do
    def size
      items.values.sum(0, &:size)
    end
  end
end

root = AOC::Directory.new
current_path = [root]
directories = [root]

commands = ARGF
  .each_line
  .drop(1) # Remove the first "cd /", we assumed it with root
  .map(&:chomp)
  .chunk_while { |l1, l2| l2[0] != "$" }
  .to_a

commands.each do |command, *outputs|
  case command.split[1..]
  in ["cd", ".."]
    current_path.pop
  in ["cd", dir]
    current_path << current_path.last.items.fetch(dir)
  in ["ls"]
    current_path.last.items =
      outputs.each.with_object({}) do |line, items|
        case line.split(" ")
        in ["dir", name]
          items[name] = AOC::Directory.new
          directories << items[name]
        in [size, name]
          items[name] = AOC::File.new(Integer(size))
        else
          raise
        end
      end
  else
    raise
  end
end

# Part 1
puts directories.select { _1.size <= 100_000 }.sum(&:size)

# Part 2
space_to_free = 30_000_000 - (70_000_000 - root.size)
puts directories.reject { _1.size < space_to_free }.sort_by(&:size).first.size
