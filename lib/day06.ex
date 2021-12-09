defmodule Advent6 do
  def read_timers(file_name) do
    file_name
    |> File.read!()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def simulate_days(timers, days) do
    timers = Enum.frequencies(timers)
    (1..days)
    |> Enum.reduce(timers, fn _, prev -> day(prev) end)
    |> Map.values()
    |> Enum.sum()
  end

  # Map<days-to-spawn, number of fimsh>
  def day(timer_counts) do
    timer_counts
    |> Enum.to_list()
    |> Enum.flat_map(fn {timer, count} ->
      if timer == 0 do
        [{6, count}, {8, count}]
      else
        [{timer - 1, count}]
      end
    end)
    |> Enum.reduce(Map.new(), fn {timer, count}, map ->
      Map.update(map, timer, count, & &1 + count)
    end)
  end
end

input = Advent6.read_timers("input/6.txt")
input |> Advent6.simulate_days(80) |> IO.puts()
input |> Advent6.simulate_days(256) |> IO.puts()
