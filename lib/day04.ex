defmodule Advent4 do
  # Boards are represented as a list of possible winning lines.
  # Each line is a set of the numbers in the lines that haven't been picked yet.
  # Once a board has an empty set in it, the game is won.
  def read_bingo(file_name) do
    [moves | boards] =
      file_name
      |> File.read!()
      |> String.split("\n\n")

    moves = moves
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {moves, boards |> Enum.map(&parse_board/1) |> Enum.map(&line_sets/1)}
  end

  def parse_board(board) do
    board
      |> String.split("\n")
      |> Enum.map(fn line -> line
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)
  end

  def line_sets(board) do
    [ board, Utils.transpose(board) ]
    |> Enum.flat_map(fn b -> Enum.map(b, &MapSet.new/1) end)
  end

  def score(board, move) do
      leftovers = board
        |> Enum.flat_map(&Enum.to_list/1)
        |> Enum.uniq()
      Enum.sum(leftovers) * move
  end

  def play_round_on_board(board, move) do
    board = board |> Enum.map(& MapSet.delete(&1, move))
    won? = not (board |> Enum.filter(&Enum.empty?/1) |> Enum.empty?)
    {board, won?}
  end

  def play(boards, [move | moves]) do
    boards_with_completions = Enum.map(boards, & play_round_on_board(&1, move))
    {boards, completions} = boards_with_completions |> Enum.unzip()
    if Enum.any?(completions) do
      [{winning_board, _}] = boards_with_completions
        |> Enum.filter(& elem(&1, 1))
      score(winning_board, move)
    else
      play(boards, moves)
    end
  end

  # Boards get dropped when they complete. Last board to complete wins.
  def play_to_last(boards, [move | moves]) do
    boards_with_completions = Enum.map(boards, & play_round_on_board(&1, move))
    case boards_with_completions do
      [{winning_board, true}] -> score(winning_board, move)
      _ ->
        unfinished_boards =
          boards_with_completions
          |> Enum.filter(fn {_, complete?} -> not complete? end)
          |> Enum.map(fn {board, _} -> board end)
        play_to_last(unfinished_boards, moves)
    end
  end
end

{moves, boards} = Advent4.read_bingo("input/4-sample.txt")
Advent4.play(boards, moves) |> IO.puts
Advent4.play_to_last(boards, moves) |> IO.puts
