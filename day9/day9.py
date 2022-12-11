import sys

from dataclasses import dataclass
from typing import Iterator, Tuple

def clamp(i: int) -> int:
    return max(min(i, 1), -1)

Direction = Tuple[int, int]
Instruction = Tuple[Direction, int]

@dataclass(frozen=True)
class Position:
    i: int
    j: int

    def move_to(self, direction: Direction) -> "Position":
        di, dj = direction
        return Position(self.i + di, self.j + dj)

    def follow_other(self, other: "Position") -> "Position":
        di = other.i - self.i
        dj = other.j - self.j
        if abs(di) > 1 or abs(dj) > 1:
            return self.move_to(direction=(clamp(di), clamp(dj)))
        else:
            return self

def read_instructions() -> Iterator[Instruction]:
    directions: dict[str, Direction] = {
        "R": ( 1,  0),
        "L": (-1,  0),
        "U": ( 0, -1),
        "D": ( 0,  1),
    }
    with open(sys.argv[1], 'r') as file:
        for line in file:
            d, n = line.split(" ")
            yield (directions[d], int(n))

N = 10

zero = Position(0, 0)
positions = [zero] * N
tail_visited_positions = {zero}

for direction, number_of_moves in read_instructions():
    for _ in range(number_of_moves):
        positions[0] = positions[0].move_to(direction)
        for i in range(1, N):
            positions[i] = positions[i].follow_other(positions[i - 1])

        tail_visited_positions.add(positions[-1])

print(len(tail_visited_positions))
