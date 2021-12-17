defmodule Advent17 do
  def read_target_area(file_name) do
    contents = File.read!(file_name)
    [min_x, max_x, min_y, max_y] = Regex.run(
      ~r/^target area: x=(-?[0-9]+)..(-?[0-9]+), y=(-?[0-9]+)..(-?[0-9]+)$/,
      contents,
      [capture: :all_but_first]
    ) |> Enum.map(&String.to_integer/1)
    {{min_x, max_x}, {min_y, max_y}}
  end

  def highest_point_in_trajectory_to_target({_, {min_y, _}} = target_area) do
    # vertical velocity is parabolic, always cross x axis at starting speed
    # so fastest you can go up is the max distance you can go down
    highest_potential_y = -min_y
    {{_, traj_y}, :hit} =
      Stream.iterate(highest_potential_y, & &1 - 1)
      |> Stream.flat_map(fn traj_y ->
        Stream.iterate(0, fn traj_x -> traj_x + 1 end)
        |> Stream.map(fn traj_x ->
          {{traj_x, traj_y}, trajectory_result({traj_x, traj_y}, target_area)}
        end)
        |> Stream.take_while(fn {_, result} -> result != :overshoot end)
      end)
      |> Stream.filter(fn {_, result} -> result == :hit end)
      |> Enum.at(0)
      div((traj_y + 1) * traj_y, 2)
  end

  def all_initial_velocities_to_target({_, {min_y, _}} = target_area) do
    min_y..-min_y
      |> Stream.flat_map(fn traj_y ->
        Stream.iterate(0, fn traj_x -> traj_x + 1 end)
        |> Stream.map(fn traj_x ->
          {{traj_x, traj_y}, trajectory_result({traj_x, traj_y}, target_area)}
        end)
        |> Stream.take_while(fn {_, result} -> result != :overshoot end)
      end)
      |> Stream.filter(fn {_, result} -> result == :hit end)
      |> Stream.map(fn {traj, _} -> traj end)
      |> Enum.to_list()
  end

  def trajectory_result(traj, target_area) do
    trajectory_result({0, 0}, 0, traj, target_area)
  end

  def trajectory_result({x0, y0}, prev_y, {traj_x0, traj_y0}, {{min_x, max_x}, {min_y, max_y}} = target_area) do
    cond do
      x0 > max_x and y0 >= min_y and prev_y > max_y -> :overshoot
      x0 > max_x and y0 >= min_y -> :undershoot
      x0 > max_x or y0 < min_y -> :undershoot
      x0 >= min_x and x0 <= max_x and y0 >= min_y and y0 <= max_y -> :hit
      true ->
        traj_x = max(traj_x0 - 1, 0)
        traj_y  = traj_y0 - 1
        trajectory_result({x0 + traj_x0, y0 + traj_y0}, y0, {traj_x, traj_y}, target_area)
    end
  end
end

input = Advent17.read_target_area("input/17.txt")
input |> Advent17.highest_point_in_trajectory_to_target() |> IO.inspect()
input |> Advent17.all_initial_velocities_to_target() |> Enum.count() |> IO.inspect()
