defmodule Advent22b do
  def read_reboot_steps(file_name) do
    File.read!(file_name)
    |> String.split("\n")
    |> Enum.map(fn line ->
      [on_off, coord_string] = Regex.run(~r/(on|off) (.*)/, line, [capture: :all_but_first])
      coords = Regex.run(
          ~r/x=(-?[0-9]+)\.\.(-?[0-9]+),y=(-?[0-9]+)\.\.(-?[0-9]+),z=(-?[0-9]+)\.\.(-?[0-9]+)/,
          coord_string,
          [capture: :all_but_first]
        )
        |> Enum.map(&String.to_integer/1)
        |> Enum.chunk_every(2)
        |> Enum.map(&List.to_tuple/1)
        |> List.to_tuple()
      {on_off == "on", coords}
    end)
  end

  def subdivide_intervals({a_min, a_max}, {b_min, b_max}) do
    cond do
      # non overlapping before current
      a_max < b_min -> [{a_min, a_max}, {b_min, b_max}]
      # non overlapping after current
      a_min > b_max -> [{b_min, b_max}, {a_min, a_max}]
      # rest are overlapping
      # A  [....]
      # B     [....]
      # =  [.][.][.]
      a_min < b_min and a_max < b_max -> [{a_min, b_min - 1}, {b_min, a_max}, {a_max + 1, b_max}]
      # A  [.....]
      # B     [..]
      # =  [.][..]
      a_min < b_min and a_max == b_max -> [{a_min, b_min - 1}, {b_min, a_max}]
      # A  [.......]
      # B     [.]
      # =  [.][.][.]
      a_min < b_min and a_max > b_max -> [{a_min, b_min - 1}, {b_min, b_max}, {b_max + 1, a_max}]
      # A  [..]
      # B  [.....]
      # =  [..][.]
      a_min == b_min and a_max < b_max -> [{a_min, a_max}, {a_max + 1, b_max}]
      # A  [....]
      # B  [....]
      # =  [....]
      a_min == b_min and a_max == b_max -> [{a_min, a_max}]
      # A  [.....]
      # B  [..]
      # =  [..][.]
      a_min == b_min and a_max > b_max -> [{b_min, b_max}, {b_max + 1, a_max}]
      # A     [.]
      # B  [.......]
      # =  [.][.][.]
      a_min > b_min and a_max < b_max -> [{b_min, a_min - 1}, {a_min, a_max}, {a_max + 1, b_max}]
      # A     [..]
      # B  [.....]
      # =  [.][..]
      a_min > b_min and a_max == b_max -> [{b_min, a_min - 1}, {a_min, a_max}]
      # A     [....]
      # B  [....]
      # =  [.][.][.]
      a_min > b_min and a_max > b_max -> [{b_min, a_min - 1}, {a_min, b_max}, {b_max + 1, a_max}]
    end
  end

  def subdivide_prisms(
    {x0, y0, z0},
    {x1, y1, z1}
  ) do
    for x <- subdivide_intervals(x0, x1), y <- subdivide_intervals(y0, y1), z <- subdivide_intervals(z0, z1), do:
      {x, y, z}
  end

  def range_overlap?({a_min, a_max}, {b_min, b_max}) do
    a_min <= b_max and a_max >= b_min
  end

  def prism_overlap?(
    {a_x, a_y, a_z},
    {b_x, b_y, b_z}
  ) do
    range_overlap?(a_x, b_x) and range_overlap?(a_y, b_y) and range_overlap?(a_z, b_z)
  end

  def range_in?({inner_min, inner_max}, {outer_min, outer_max}) do
    inner_min >= outer_min and inner_max <= outer_max
  end

  def prism_in?(
    {inner_x, inner_y, inner_z},
    {outer_x, outer_y, outer_z}
  ) do
    range_in?(inner_x, outer_x) and range_in?(inner_y, outer_y) and range_in?(inner_z, outer_z)
  end

  def subtract_prism(on, off) do
    if prism_overlap?(on, off) do
      # subdivide the bounding box of both prisms along the boundaries of the two prisms and
      # only return the subprisms that started on and shouldn't be turned off
      subdivide_prisms(on, off)
        |> Enum.filter(fn sub -> prism_in?(sub, on) and not prism_in?(sub, off) end)
    else
      [on]
    end
  end

  def apply_step({on?, prism}, on_prisms) do
    # addition is implemented as a deletion then an addition to avoid overlaps
    without_new_prism = on_prisms |> Enum.flat_map(fn on -> subtract_prism(on, prism) end)
    if on? do
      [prism | without_new_prism]
    else
      without_new_prism
    end
  end

  def count_on(steps) do
    Enum.reduce(steps, [], &apply_step/2)
    |> Enum.map(fn {{x0, x1}, {y0, y1}, {z0, z1}} -> (x1 - x0 + 1) * (y1 - y0 + 1) * (z1 - z0 + 1) end)
    |> Enum.sum()
  end
end

input = Advent22b.read_reboot_steps("input/22.txt")
input
  |> Enum.filter(fn {_, {x, y, z}} ->
    Advent22b.range_in?(x, {-50, 50}) and
    Advent22b.range_in?(y, {-50, 50}) and
    Advent22b.range_in?(z, {-50, 50}) end)
  |> Advent22b.count_on()
  |> IO.inspect()
input |> Advent22b.count_on() |> IO.inspect()
