defmodule Advent4 do
  def read_bingo(file_name) do
    [moves | boards] =
      file_name
      |> File.read!()
      |> String.split("\n\n")

    moves = moves
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    boards = Enum.map(boards, fn board -> board
      |> String.split("\n")
      |> Enum.map(fn line -> line
        |> String.split(" ")
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&String.to_integer/1)
      end)
    end)

    {moves, boards |> Enum.map(&lines/1)}
  end

  def lines(board) do
    board = board
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row |> Enum.with_index(fn value, x -> {{x, y}, value} end)
      end)
      |> Map.new()

    [
      0..4 |> Enum.to_list() |> Enum.map(fn row ->
        0..4 |> Enum.to_list() |> Enum.map(&(board[{&1, row}])) |> MapSet.new()
      end),
      0..4 |> Enum.to_list() |> Enum.map(fn col ->
        0..4 |> Enum.to_list() |> Enum.map(&(board[{col, &1}])) |> MapSet.new()
      end),
      #0..4 |> Enum.to_list() |> Enum.map(&(board[{&1, &1}])) |> MapSet.new(),
      #0..4 |> Enum.to_list() |> Enum.map(&(board[{4 - &1, &1}])) |> MapSet.new()
    ]
    |> List.flatten()
  end

  def score(board, move) do
      leftovers = board
        |> Enum.flat_map(&Enum.to_list/1)
        |> Enum.uniq()
      Enum.sum(leftovers) * move
  end

  def play(boards, [move | moves]) do
    boards_with_completions = Enum.map(boards, &(play_board(&1, move)))
    {boards, completions} = boards_with_completions |> Enum.unzip()
    if Enum.any?(completions) do
      [winning_board] = boards_with_completions
        |> Enum.filter(&(elem(&1, 1)))
        |> Enum.map(&(elem(&1, 0)))
      score(winning_board, move)
    else
      play(boards, moves)
    end
  end

  def play_to_last(boards, [move | moves]) do
    boards_with_completions = Enum.map(boards, &(play_board(&1, move)))
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

  def play_board(board, move) do
    board = board |> Enum.map(&(MapSet.delete(&1, move)))
    won? = not (board |> Enum.filter(&Enum.empty?/1) |> Enum.empty?)
    {board, won?}
  end
end

{moves, boards} = Advent4.read_bingo("input/4-sample.txt")
Advent4.play(boards, moves) |> IO.puts
Advent4.play_to_last(boards, moves) |> IO.puts
