# Solution inspired by the excellent work here:
# https://github.com/juanplopes/advent-of-code-2022/blob/main/day16.py

struct Valve
  getter :name, :rate, :links, :bitmask

  def initialize(
    @name : String,
    @rate : Int32,
    @links : Array(String),
    @bitmask : UInt64
  ); end
end

def parse_input(io : IO)
  valves = Hash(String, Valve).new
  io.each_line.with_index do |line, index|
    match_result = line.match(/Valve (?<name>[A-Z]{2}) has flow rate=(?<rate>\d+); tunnels? leads? to valves? (?<tunnels>[A-Z]{2}(, [A-Z]{2})*)/)
    raise "Unknown line: #{line}" unless match_result

    name, rate, links = match_result.named_captures.values
    raise "Missing name, rate or links for line: #{line}" unless name && rate && links

    valves[name] = Valve.new(name, rate.to_i, links.split(", "), UInt64.new(1) << index)
  end
  valves
end

def build_distances(valves : Hash(String, Valve))
  distances = Hash(Tuple(String, String), Int32 | Nil).new do |hash, tuple|
    name_a, name_b = tuple
    hash[tuple] = valves[name_a].links.any? { |link_name| link_name == name_b } ? 1 : nil
  end
  valves.keys.each do |name_k|
    valves.keys.each do |name_i|
      valves.keys.each do |name_j|
        dij, dik, dkj = distances.values_at({name_i, name_j}, {name_i, name_k}, {name_k, name_j})
        distances[{name_i, name_j}] = dik + dkj if dik && dkj && (dij.nil? || (dik + dkj) < dij)
      end
    end
  end
  distances
end

def fill_max_scores(
  distances : Hash(Tuple(String, String), Int32 | Nil),
  valves : Array(Valve),
  position : String,
  minutes_left : Int32,
  open_valves : UInt64,
  score : Int32,
  answers : Hash(UInt64, Int32),
)
  return if minutes_left < 0
  answers[open_valves] = score if answers.fetch(open_valves, 0) < score
  valves.each do |valve|
    next if valve.bitmask & open_valves > 0
    next_minutes_left = minutes_left - distances[{position, valve.name}].as(Int32) - 1
    fill_max_scores(
      distances,
      valves,
      valve.name,
      next_minutes_left,
      open_valves | valve.bitmask,
      score + valve.rate * next_minutes_left,
      answers,
    )
  end
end

valves = parse_input(ARGF)
non_zero_valves = valves.values.select { |valve| valve.rate > 0 }
distances = build_distances(valves)

# Part 1
max_scores = Hash(UInt64, Int32).new
fill_max_scores(build_distances(valves), non_zero_valves, "AA", 30, UInt64.new(0), 0, max_scores)
puts max_scores.values.max

# Part 2
max_combination = 0
max_scores = Hash(UInt64, Int32).new
fill_max_scores(build_distances(valves), non_zero_valves, "AA", 26, UInt64.new(0), 0, max_scores)
max_scores.each do |open_valves_1, score_1|
  max_scores.each do |open_valves_2, score_2|
    if open_valves_1 & open_valves_2 == 0
      candidate_score = score_1 + score_2
      max_combination = candidate_score if candidate_score > max_combination
    end
  end
end
puts max_combination
