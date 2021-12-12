defmodule Advent10 do
  def read_chunks(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  def analyze_chunk(chunk), do: analyze_chunk(chunk, [])
  def analyze_chunk([], []), do: {:valid, [], []}
  def analyze_chunk([], opener_stack), do: {:incomplete, [], opener_stack}
  def analyze_chunk([next | rest], []) do
    if not close_char?(next) do
      analyze_chunk(rest, [next])
    else
      {:corrupted, [next | rest], []}
    end
  end
  def analyze_chunk([next | rest], [latest_unpaired_opener | remaining_opener_stack] = opener_stack) do
    cond do
      pair?(latest_unpaired_opener, next) -> analyze_chunk(rest, remaining_opener_stack)
      close_char?(next)                   -> {:corrupted, [next | rest], opener_stack}
      true                                -> analyze_chunk(rest, [next | opener_stack])
    end
  end

  def close_char?(char), do: char in [")", "]", "}", ">"]

  def pair?(opener, closer) do
    %{"(" => ")", "[" => "]", "{" => "}", "<" => ">"}[opener] == closer
  end

  def corrupt_score([invalid_closer | _]) do
    %{")" => 3, "]" => 57, "}" => 1197, ">" => 25137}[invalid_closer]
  end

  def incomplete_score(unpaired_opener_stack) do
    Enum.reduce(unpaired_opener_stack, 0, fn char, acc ->
      acc * 5 + %{"(" => 1, "[" => 2, "{" => 3, "<" => 4}[char]
    end)
  end
end

input = Advent10.read_chunks("input/10.txt")
input
  |> Enum.map(&Advent10.analyze_chunk/1)
  |> Enum.filter(fn {result, _, _} -> result == :corrupted end)
  |> Enum.map(fn {_, remaining_chars, _} -> Advent10.corrupt_score(remaining_chars) end)
  |> Enum.sum()
  |> IO.puts()
input
  |> Enum.map(&Advent10.analyze_chunk/1)
  |> Enum.filter(fn {result, _, _} -> result == :incomplete end)
  |> Enum.map(fn {_, _, opener_stack} -> Advent10.incomplete_score(opener_stack) end)
  |> Enum.sort()
  |> then(& Enum.at(&1, div(Enum.count(&1), 2)))
  |> IO.puts()
