defmodule Advent11 do
  def read_energies(file_name) do
    file_name
    |> File.read!()
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

  def increment(energies), do: Map.map(energies, fn {k, v} -> v + 1 end)

  def flash_all(energies) do
    energies
    |> Enum.filter(fn {_, energy} -> energy > 9 end)
    |> Enum.reduce(energies, fn {coord, _}, energies -> flash_coord(energies, coord) end)
  end

  def flash_coord(energies, coord) do
    if energies[coord] > 9 do
      surroundings = surrounding_coords(coord)
      flashed = Enum.reduce(surroundings, energies, fn c, es ->
        Map.update!(es, c, & if &1 == 0 do 0 else &1 + 1 end)
      end)
      zeroed = Map.put(flashed, coord, 0)

      surroundings
      |> Enum.filter(& zeroed[&1] > 9)
      |> Enum.reduce(zeroed, fn c, es -> flash_coord(es, c) end)
    else
      energies
    end
  end

  def surrounding_coords({x0, y0}) do
    (for d_x <- -1..1, d_y <- -1..1, do: {x0 + d_x, y0 + d_y})
    |> Enum.filter(fn {x, y} -> (x != x0 or y != y0) && x >= 0 && x <= 9 && y >= 0 && y <= 9 end)
  end

  def count_flashes(energies, cycles) do
    Stream.iterate(energies, & flash_all(increment(&1)))
    |> Stream.take(cycles)
    |> Stream.map(fn energies -> Map.values(energies) |> Enum.count(& &1 == 0) end)
    |> Enum.sum()
  end

  def index_of_synchronization(energies) do
    Stream.iterate(energies, & flash_all(increment(&1)))
    |> Stream.with_index()
    |> Stream.drop_while(fn {es, _} ->
      Enum.any?(Map.values(es), & &1 != 0)
    end)
    |> Stream.take(1)
    |> Enum.to_list()
    |> hd()
    |> then(fn {_, index} -> index end)
  end
end

input = Advent11.read_energies("input/11.txt")
input |> Advent11.count_flashes(100) |> IO.puts()
input |> Advent11.index_of_synchronization() |> IO.puts()
