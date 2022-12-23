# Heavily inspired by https://github.com/juanplopes/advent-of-code-2022/blob/main/day16.py

require "set"

Valve = Struct.new(:name, :rate, :tunnels)

# Follows https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm
# to build a quick directory of the shortest path from one valve to another.
class Distance
  def initialize(valves_by_name)
    @valves_by_name = valves_by_name
    @valves_count = valves_by_name.size
    @shortest_path_matrix = build_shortest_path_matrix
  end

  def between(name_a, name_b)
    @shortest_path_matrix[name_a][name_b]
  end

  private

  def build_shortest_path_matrix
    matrix = Hash.new do |h1, name_a|
      h1[name_a] = Hash.new do |h2, name_b|
        h2[name_b] = @valves_by_name[name_a].tunnels.member?(name_b) ? 1 : nil
      end
    end

    @valves_by_name.keys.each do |name_k|
      @valves_by_name.keys.each do |name_a|
        @valves_by_name.keys.each do |name_b|
          a_k = matrix[name_a][name_k]
          k_b = matrix[name_k][name_b]
          matrix[name_a][name_b] = [matrix[name_a][name_b], a_k + k_b].compact.min if a_k && k_b
        end
      end
    end

    matrix
  end
end

class MaxScore
  def initialize(valves)
    @valves = valves
    @distances = Distance.new(valves)
    @to_open = valves.keys.each.select { @valves[_1].rate > 0 }
  end

  def max_scores_in_minutes(minutes_left, position, open_valves = nil, score = 0, max_scores = nil)
    open_valves ||= Set.new
    max_scores ||= Hash.new { 0 }

    @to_open.each do |valve_name| # DFS carrying the score of the path to the leafs
      next if open_valves.member?(valve_name)

      minutes_left_after_valve = minutes_left - @distances.between(position, valve_name) - 1
      if minutes_left_after_valve > 0
        max_scores_in_minutes(
          minutes_left_after_valve,
          valve_name,
          open_valves | [valve_name],
          score + @valves[valve_name].rate * minutes_left_after_valve,
          max_scores,
        )
      else # We can't open this valve, it's the end of the road, keep this score if it's the best one
        max_scores[open_valves] = score if max_scores[open_valves] < score
      end
    end

    max_scores # Hash open_valves -> max score
  end
end

valves = ARGF.each_line
  .map { _1.match(/Valve (?<name>[A-Z]{2}) has flow rate=(?<rate>\d+); tunnels? leads? to valves? (?<tunnels>[A-Z]{2}(, [A-Z]{2})*)/) }
  .map { Valve.new(_1[:name], _1[:rate].to_i, Set.new(_1[:tunnels].split(', '))) }
  .each.with_object({}) { |valve, index| index[valve.name] = valve }

ms = MaxScore.new(valves)

# Part 1
puts ms.max_scores_in_minutes(30, "AA").values.max

# Part 2
max_scores = ms.max_scores_in_minutes(26, "AA")
max_combination = max_scores.flat_map do |o1, s1|
  max_scores.each.drop_while { |k, _| k != o1 }.filter_map do |o2, s2|
    s1 + s2 if (o1 & o2).empty?
  end
end.max
puts max_combination
