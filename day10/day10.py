import sys

from dataclasses import dataclass
from typing import Iterator

@dataclass
class Instruction:
    duration: int
    position_diff: int

    @staticmethod
    def parse(line: str) -> "Instruction":
        match line.strip().split(" "):
            case ["noop"]:
                return Instruction(1, 0)
            case ["addx", diff]:
                return Instruction(2, int(diff))
            case i:
                raise ValueError(f"Unknown instruction: {i}")

def read_instructions() -> Iterator[Instruction]:
    with open(sys.argv[1], 'r') as file:
        for line in file:
            yield Instruction.parse(line)

Position = int

def simulate(instructions: Iterator[Instruction]) -> Iterator[Position]:
    position: Position = 1
    for instruction in instructions:
        for _ in range(instruction.duration):
            yield position
        position = position + instruction.position_diff
    yield position

def part_1() -> None:
    states = simulate(instructions=read_instructions())
    cycles = {20, 60, 100, 140, 180, 220}
    intensity_sum = sum(
        position * cycle
        for cycle, position in enumerate(states, start=1)
        if cycle in cycles
    )
    print(intensity_sum)

def part_2() -> None:
    states = simulate(instructions=read_instructions())
    for _ in range(6):
        for crt_position in range(40):
            position = next(states)
            is_lit = abs(crt_position - position) <= 1
            print("#" if is_lit else " ", end="")
        print("")

if __name__ == "__main__":
    part_1()
    part_2()
