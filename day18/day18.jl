struct Position
  x::Int
  y::Int
  z::Int
end

struct Box
  max_x::Int
  min_x::Int
  max_y::Int
  min_y::Int
  max_z::Int
  min_z::Int
end

function Box(positions::Vector{Position}, border::Int)::Box
  min_x, max_x = extrema(c -> c.x, positions)
  min_y, max_y = extrema(c -> c.y, positions)
  min_z, max_z = extrema(c -> c.z, positions)
  Box(max_x + border, min_x - border,
      max_y + border, min_y - border,
      max_z + border, min_z - border)
end

function Base.in(position::Position, box::Box)::Bool
  (position.x >= box.min_x && position.x <= box.max_x &&
   position.y >= box.min_y && position.y <= box.max_y &&
   position.z >= box.min_z && position.z <= box.max_z)
end

neighbors(position::Position)::Vector{Position} = [
  Position(position.x+1, position.y, position.z),
  Position(position.x-1, position.y, position.z),
  Position(position.x, position.y+1, position.z),
  Position(position.x, position.y-1, position.z),
  Position(position.x, position.y, position.z+1),
  Position(position.x, position.y, position.z-1),
]

function parse_input(filename::String)::Vector{Position}
  positions = []
  parseInt(s) = parse(Int16, s)
  for line in readlines(filename)
    x, y, z = map(parseInt, split(line, ","))
    push!(positions, Position(x, y, z))
  end
  return positions
end

parse_input() = parse_input(ARGS[1])

function part_1()
  # Count faces with a neightbor that's "not lava"
  positions = parse_input()
  index = Set(positions)
  total = 0
  for position in positions
    for n in neighbors(position)
      if !(n in index)
        total += 1
      end
    end
  end
  println(total)
end

function part_2()
  positions::Vector{Position} = parse_input()
  index = Set(positions)

  bounding_box::Box = Box(positions, 1)

  # Explore the outside, stop at the bounding box or when encountering lava
  start_position = Position(bounding_box.min_x, bounding_box.min_y, bounding_box.min_z)
  to_explore::Vector{Position} = [start_position]
  outside_positions::Set{Position} = Set(to_explore)
  while !isempty(to_explore)
    position = popfirst!(to_explore)
    for neighbor in neighbors(position)
      if neighbor in bounding_box && !(neighbor in outside_positions) && !(neighbor in index)
        push!(outside_positions, neighbor)
        push!(to_explore, neighbor)
      end
    end
  end

  # Count the faces that are in contact with the outside_positions
  total = 0
  for position in positions
    for n in neighbors(position)
      if n in outside_positions
        total += 1
      end
    end
  end

  println(total)
end

part_1()
part_2()
