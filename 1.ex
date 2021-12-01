defmodule Advent1 do
  def read_depths(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&(String.to_integer(&1)))
  end

  def count_window_increases(list, window_size) do
    list
    |> Enum.chunk_every(window_size, 1, :discard)
    |> Enum.count(&(List.first(&1) < List.last(&1)))
  end
end

input = Advent1.read_depths("input/1.txt")
IO.puts(Advent1.count_window_increases(input, 2))
IO.puts(Advent1.count_window_increases(input, 4))
