defmodule Advent5 do
  def read_lines(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(fn coord -> coord
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  def map_vents(lines) do
    Enum.flat_map(lines, fn [{x1, y1}, {x2, y2}] ->
      diff_x = x2 - x1
      diff_y = y2 - y1
      mod_x = if diff_x == 0 do 0 else div(diff_x, abs(diff_x)) end
      mod_y = if diff_y == 0 do 0 else div(diff_y, abs(diff_y)) end
      abs_diff = max(abs(diff_x), abs(diff_y))
      for d <- 0..abs_diff, do: {x1 + d * mod_x, y1 + d * mod_y}
    end)
  end
end

input = Advent5.read_lines("input/5.txt")
input
  |> Enum.filter(fn [{x1, y1}, {x2, y2}] ->
    x1 == x2 or y1 == y2
  end)
  |> Advent5.map_vents()
  |> Enum.frequencies()
  |> Enum.count(fn {_, c} -> c >= 2 end)
  |> IO.puts()
input
  |> Advent5.map_vents()
  |> Enum.frequencies()
  |> Enum.count(fn {_, c} -> c >= 2 end)
  |> IO.puts()
