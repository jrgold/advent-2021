defmodule Advent13 do
  def read_paper(file_name) do
    [points, folds] = file_name
      |> File.read!()
      |> String.split("\n\n")

    points = points
      |> String.split("\n")
      |> Enum.map(fn line -> String.split(line, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple() end)
      |> MapSet.new()

    folds = folds
      |> String.split("\n")
      |> Enum.map(fn line ->
        [axis, n] = Regex.run(~r/^fold along (.)=([0-9]+)$/, line, [capture: :all_but_first])
        {axis, String.to_integer(n)}
      end)

    {points, folds}
  end

  def count_after_one_fold({points, [first_fold | _]}) do
    points
    |> Enum.map(fn coord -> fold_point(coord, first_fold) end)
    |> MapSet.new()
    |> MapSet.size()
  end

  def apply_all_folds({points0, folds}) do
    Enum.reduce(folds, points0, fn fold, points ->
      points |> Enum.map(fn c -> fold_point(c, fold) end) |> MapSet.new()
    end)
  end

  def fold_point({x, y}, {axis, fold_pos}) do
    case axis do
      "x" ->
        if x > fold_pos do
          {fold_pos - (x - fold_pos), y}
        else
          {x, y}
        end
      "y" ->
        if y > fold_pos do
          {x, fold_pos - (y - fold_pos)}
        else
          {x, y}
        end
    end
  end
end

input = Advent13.read_paper("input/13.txt")
input |> Advent13.count_after_one_fold() |> IO.puts()
input |> Advent13.apply_all_folds() |> Map.new(& {&1, "#"}) |> Utils.print_sparse_grid()
