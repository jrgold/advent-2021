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

  def print_sparse_grid(sparse_grid) do
    {min_x, max_x} = sparse_grid |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = sparse_grid |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.min_max()

    (for x <- min_x..max_x, y <- min_y..max_y, do: {x, y})
      |> Enum.reduce(sparse_grid, fn coord, grid -> Map.put_new(grid, coord, " ") end)
      |> print_grid()
  end

  def read_grid(string) do
    string
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      String.graphemes(line)
      |> Enum.with_index(fn energy, x ->
        {{x, y}, String.to_integer(energy)}
      end)
    end)
    |> Map.new()
  end
end
