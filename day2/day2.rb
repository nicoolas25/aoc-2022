ROCK = Object.new
PAPER = Object.new
SCISSORS = Object.new

POINTS_PER_SHAPE = {
  ROCK => 1,
  PAPER => 2,
  SCISSORS => 3,
}.freeze

SHAPE_READER = {
  "A" => ROCK,
  "B" => PAPER,
  "C" => SCISSORS,
}.freeze

LOSE = Object.new
DRAW = Object.new
WIN = Object.new

ISSUE_READER = {
  "X" => LOSE,
  "Y" => DRAW,
  "Z" => WIN,
}.freeze

POINT_PER_ISSUE = {
  LOSE => 0,
  DRAW => 3,
  WIN => 6,
}.freeze

RESPONSES = {
  [ROCK, WIN] => PAPER,
  [ROCK, LOSE] => SCISSORS,
  [ROCK, DRAW] => ROCK,

  [PAPER, WIN] => SCISSORS,
  [PAPER, LOSE] => ROCK,
  [PAPER, DRAW] => PAPER,

  [SCISSORS, WIN] => ROCK,
  [SCISSORS, LOSE] => PAPER,
  [SCISSORS, DRAW] => SCISSORS,
}.freeze

total = ARGF
  .each_line
  .map(&:chomp)
  .map { |line|
    other_shape, expected_issue = line.split
    other_shape = SHAPE_READER.fetch(other_shape)
    expected_issue = ISSUE_READER.fetch(expected_issue)
    my_shape = RESPONSES.fetch([other_shape, expected_issue])
    POINT_PER_ISSUE.fetch(expected_issue) + POINTS_PER_SHAPE.fetch(my_shape)
  }
  .sum

puts total
