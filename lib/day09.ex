defmodule Advent9 do
  def read_heightmap(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {height_string, x} ->
        {{x, y}, String.to_integer(height_string)}
      end)
    end)
    |> Map.new()
  end

  def surrounding_coords({x, y}), do: [
        {x - 1, y    },
        {x + 1, y    },
        {x    , y - 1},
        {x    , y + 1}
  ]

  def lowest_points(heightmap) do
    heightmap
    |> Enum.filter(fn {coord, height} ->
      surrounding_coords(coord)
      # Points off the edge are "higher" than real points
      |> Enum.map(& height < Map.get(heightmap, &1, 10))
      |> Enum.all?()
    end)
  end

  # Flood fill
  # Try to add surrounding points to basin, recurse if newly-found basin coordinate
  def fill_basin(heightmap, coord), do: fill_basin(heightmap, MapSet.new(), coord)
  @spec fill_basin(any, any, {number, number}) :: any
  def fill_basin(heightmap, basin, coord) do
    surrounding_coords(coord)
    |> Enum.reduce(basin, fn next_coord, basin ->
      delongs_in_basin = Map.get(heightmap, next_coord, 10) < 9
      not_yet_in_basin = not MapSet.member?(basin, next_coord)
      if delongs_in_basin and not_yet_in_basin do
        fill_basin(heightmap, MapSet.put(basin, next_coord), next_coord)
      else
        basin
      end
    end)
  end

  def basins_from_big_to_small(heightmap) do
    heightmap
    |> Advent9.lowest_points()
    |> Enum.map(fn {coord, _} -> fill_basin(heightmap, coord) end)
    |> Enum.sort_by(&MapSet.size/1)
    |> Enum.reverse()
  end
end

input = Advent9.read_heightmap("input/9.txt")
input
  |> Advent9.lowest_points()
  |> Enum.map(fn {_, height} -> 1 + height end)
  |> Enum.sum()
  |> IO.puts()
input
  |> Advent9.basins_from_big_to_small()
  |> Enum.take(3)
  |> Enum.map(&MapSet.size/1)
  |> Enum.product()
  |> IO.puts()
