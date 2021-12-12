defmodule Advent12 do
  def read_cave_links(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split("-")
      |> List.to_tuple()
    end)
    |> Enum.flat_map(fn {c1, c2} -> [{c1, c2}, {c2, c1}] end)
    |> Enum.group_by(fn {c1, _} -> c1 end, fn {_, c2} -> c2 end)
    |> Map.new()
  end

  def small?(name), do: String.downcase(name) == name

  def paths(cave_links, can_visit?), do: paths(cave_links, can_visit?, [], "start")
  def paths(_         , _         , previous_caves, "end"), do: [["end" | previous_caves]]
  def paths(cave_links, can_visit?, previous_caves,  cave) do
    cave_links[cave]
    |> Enum.filter(fn next_cave -> can_visit?.(previous_caves, next_cave) end)
    |> Enum.flat_map(fn next_cave ->
      paths(cave_links, can_visit?, [next_cave | previous_caves], next_cave)
    end)
  end

  def can_visit_small_caves_only_once(previous_caves, cave) do
    not small?(cave) or cave not in previous_caves
  end

  def can_visit_one_small_cave_twice(previous_caves, cave) do
    cave != "start" and (
         not small?(cave)
      or cave not in previous_caves
      or not small_cave_visited_twice_yet?(previous_caves)
    )
  end

  def small_cave_visited_twice_yet?(visited) do
    visited
    |> Enum.filter(&small?/1)
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.any?(& &1 > 1)
  end
end

input = Advent12.read_cave_links("input/12.txt")
input |> Advent12.paths(&Advent12.can_visit_small_caves_only_once/2) |> Enum.count() |> IO.puts()
input |> Advent12.paths(&Advent12.can_visit_one_small_cave_twice/2) |> Enum.count() |> IO.puts()
