defmodule Day02 do
  def read_commands(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      case String.split(line, " ") do
        ["forward", x] -> {String.to_integer(x), 0}
        ["up",      y] -> {0, -String.to_integer(y)}
        ["down",    y] -> {0, String.to_integer(y) }
      end
    end)
  end

  def sum_commands(commands) do
    commands
    |> Enum.reduce(fn {d_x, d_y}, {x0, y0} -> {x0 + d_x, y0 + d_y} end)
  end

  def aim_commands(commands) do
    commands
    |> Enum.reduce({0, 0, 0}, fn {d_x, d_aim}, {aim0, x0, y0} -> {aim0 + d_aim, x0 + d_x, y0 + aim0 * d_x} end)
  end
end

input = Day02.read_commands("input/2.txt")
input |> Day02.sum_commands |> then(fn {x, y} -> x * y end) |> IO.puts
input |> Day02.aim_commands |> then(fn {_aim, x, y} -> x * y end) |> IO.puts
