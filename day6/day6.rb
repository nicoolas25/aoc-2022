buffer = ARGF.read.chomp.each_char.to_a

N = 14
cursor = N
loop do
  if buffer.take(N).uniq.size == N
    puts cursor
    exit
  end

  buffer.shift
  cursor += 1
end
