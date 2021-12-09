defmodule Advent7 do
  def read_positions(file_name) do
    file_name
    |> File.read!()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def optimal_linear_fuel(positions) do
    middle_index = div(Enum.count(positions), 2)
    median_position = Enum.at(Enum.sort(positions), middle_index)
    positions |> Enum.map(& abs(&1 - median_position)) |> Enum.sum()
  end

  def triangular_fuel_used(positions, target) do
    positions
    |> Enum.map(fn x ->
      d_x = abs(x - target)
      div(d_x * (d_x + 1), 2)
    end)
    |> Enum.sum()
  end

  def optimal_triangular_fuel(positions) do
    min = Enum.min(positions)
    max = Enum.max(positions)
    min..max
    |> Enum.map(& triangular_fuel_used(positions, &1))
    |> Enum.min()
  end
end

input = Advent6.read_timers("input/7.txt")
input |> Advent7.optimal_linear_fuel() |> IO.puts()
input |> Advent7.optimal_triangular_fuel() |> IO.puts()
