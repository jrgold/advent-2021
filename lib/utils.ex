defmodule Utils do
  def transpose(matrix) do
    matrix
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def print_grid(grid) do
    grid
    |> Enum.group_by(fn {{_, y}, _} -> y end)
    |> Enum.sort_by(fn {y, _} -> y end)
    |> Enum.map(fn {_, row} ->
      row
      |> Enum.sort_by(fn {{x, _}, _} -> x end)
      |> Enum.map(fn {_, c} -> to_string(c) end)
      |> Enum.join()
      |> IO.puts()
    end)
  end
end
