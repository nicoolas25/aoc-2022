require "benchmark"
require "bit_array"
require "set"

record Position, i : Int32, j : Int32

class Piece
  getter :index, :positions, :min_j, :max_j

  def initialize(
    @positions : Array(Position),
    @min_j : Int32,
    @max_j : Int32,
  ); end

  def shift(di : Int32, dj : Int32)
    Piece.new(
      @positions.map { |p| Position.new(p.i + di, p.j + dj) },
      @min_j + dj,
      @max_j + dj,
    )
  end
end

PIECES = [
  Piece.new([Position.new(0, 0), Position.new(0, 1), Position.new(0, 2), Position.new(0, 3)], 0, 3),
  Piece.new([Position.new(1, 0), Position.new(0, 1), Position.new(1, 1), Position.new(1, 2), Position.new(2, 1)], 0, 2),
  Piece.new([Position.new(0, 0), Position.new(0, 1), Position.new(0, 2), Position.new(1, 2), Position.new(2, 2)], 0, 2),
  Piece.new([Position.new(0, 0), Position.new(1, 0), Position.new(2, 0), Position.new(3, 0)], 0, 0),
  Piece.new([Position.new(0, 0), Position.new(0, 1), Position.new(1, 0), Position.new(1, 1)], 0, 1),
]
PIECE_MAX_HEIGHT = 4

WIDTH = 7
HEIGHT = 30
VIEWPOST_CELLS = WIDTH * HEIGHT

struct Viewport
  @bitmap : BitArray # Internal viewport storage (ring buffer)

  def initialize(bitmap : BitArray | Nil = nil)
    @bitmap = bitmap || BitArray.new(VIEWPOST_CELLS)
  end

  def move_up!(by : Int32 = 1)
    return if by == 0

    shifted_bits = by * WIDTH
    @bitmap.rotate!(shifted_bits)
    @bitmap.fill(false, VIEWPOST_CELLS - shifted_bits, shifted_bits)
  end

  def empty?(position : Position) : Bool
    i = index(position)
    i >= VIEWPOST_CELLS || !@bitmap[i] # Assume it's empty if it's above the viewport
  end

  def fill!(position : Position)
    @bitmap[index(position)] = true
  end

  private def index(position : Position) : Int32
    position.i * WIDTH + position.j
  end

  def_hash @bitmap
end

class Chamber
  getter :viewport_moves

  @viewport : Viewport
  @viewport_di : Int32
  @viewport_moves : UInt64
  @jets : Array(Int32)
  @pieces_to_drop : UInt64
  @pieces_dropped : UInt64
  @jets_index : Int32

  def initialize(@jets : Array(Int32), @pieces_to_drop : UInt64)
    @viewport = Viewport.new
    @viewport_di = HEIGHT - 1 # For HEIGHT = 30, top i of the viewport is 29
    @viewport_moves = 0 # Record the number of i we crossed
    @pieces_dropped = 0
    @jets_index = 0

    # Cache the last time the configuration ie: (piece, jet, viewport) has been seen.
    # Keep track of the last (total moves count, pieces dropped count) so each time we
    # find ourselves in such a setup, we can increase moves and pieces dropped without
    # touching the viewport, until we're too close to the pieces to drop.
    @cache = Hash(Tuple(Int32, Int32, UInt64), Tuple(UInt64, UInt64)).new

    # Floor is 4 rows below the top of the viewport at the begining
    WIDTH.times { |j| @viewport.fill!(Position.new(@viewport_di - 4, j)) }
  end

  def empty?
    @pieces_dropped == @pieces_to_drop
  end

  def drop
    piece_index = Int32.new(@pieces_dropped % PIECES.size)
    piece = PIECES[piece_index].shift(@viewport_di, 2) # The new piece always start falling from the top of the viewport
    loop do
      # Apply jet, or maybe not when moving this way isn't possible
      j_direction = @jets[@jets_index]
      if (next_piece = attempt_move(piece, 0, j_direction))
        piece = next_piece
      end
      @jets_index = (@jets_index + 1) % @jets.size

      # Moving the piece down is either, falling or settling
      if (next_piece = attempt_move(piece, -1, 0))
        piece = next_piece
      else
        previous_max_i = max_i = @viewport_di - 4

        piece.positions.each do |p|
          max_i = p.i if p.i > max_i
          @viewport.fill!(p)
        end

        moves_up = max_i - previous_max_i
        @viewport.move_up!(moves_up)
        @viewport_moves += moves_up
        @pieces_dropped += 1
        break
      end

      cache_key = {Int32.new(@pieces_dropped % PIECES.size), @jets_index, @viewport.hash}

      if cache = @cache.fetch(cache_key, nil)
        # If we've seen that configuration before, we can "jump" a full cycle
        last_viewport_moves, last_pieces_dropped = cache
        pieces_dropped_diff = @pieces_dropped - last_pieces_dropped
        if (@pieces_dropped + pieces_dropped_diff) <= @pieces_to_drop
          @viewport_moves += @viewport_moves - last_viewport_moves
          @pieces_dropped += pieces_dropped_diff
        end
      end

      @cache[cache_key] = {@viewport_moves, @pieces_dropped}
    end
  end

  private def attempt_move(piece : Piece, di : Int32, dj : Int32) : Piece | Nil
    # Anticipate the lateral (j) boundaries of the chamber
    return nil if (dj + piece.min_j) < 0 || (dj + piece.max_j) > 6

    # Check for obstables in the viewport
    moved_piece = piece.shift(di, dj)
    moved_piece.positions.all? { |p| @viewport.empty?(p) } ? moved_piece : nil
  end
end

jets = ARGF.gets.as(String).chomp.split("").map { |c| c == "<" ? -1 : 1 }

# Part 1
chamber = Chamber.new(jets, 2022)
while !chamber.empty?
  chamber.drop
end
puts chamber.viewport_moves

# Part 2
chamber = Chamber.new(jets, 1_000_000_000_000)
while !chamber.empty?
  chamber.drop
end
puts chamber.viewport_moves
