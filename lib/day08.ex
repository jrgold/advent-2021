defmodule Advent8 do
  def read_patterns(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      [signal_patterns, outputs] =
        String.split(line, " | ")
        |> Enum.map(fn half ->
          String.split(half, " ")
          |> Enum.map(& MapSet.new(String.graphemes(&1)))
        end)
      {signal_patterns, outputs}
    end)
  end

  @spec count_uniques_in_outputs(any) :: non_neg_integer
  def count_uniques_in_outputs(patterns) do
    patterns
    |> Enum.flat_map(fn {_, outputs} ->
      Enum.filter(outputs, & MapSet.size(&1) in [2, 4, 3, 7])
    end)
    |> Enum.count()
  end

  def decode_signal_patterns(signal_patterns) do
    by_number_of_segments = signal_patterns |> Enum.group_by(& MapSet.size(&1))

    # 1
    c_f = hd(by_number_of_segments[2])
    # 4
    b_c_d_f = hd(by_number_of_segments[4])
    # 7
    a_c_f = hd(by_number_of_segments[3])
    # 8
    a_b_c_d_e_f_g = hd(by_number_of_segments[7])

    # the segments that appear twice out of 0, 6, 9 are c, d, and e
    c_d_e = by_number_of_segments[6] |> segments_occuring_n_times(2)
    # the segments that appear once out of 2, 3, 5 are b and e
    b_e = by_number_of_segments[5] |> segments_occuring_n_times(1)

    a = diff(a_c_f, [c_f])
    f = diff(c_f, [c_d_e])
    c = diff(c_f, [f])
    e = diff(c_d_e, [b_c_d_f])
    b = diff(b_e, [e])
    g = diff(a_b_c_d_e_f_g, [a, b, c_d_e, f])
    d = diff(a_b_c_d_e_f_g, [a, b, c, e, f, g])

    %{
      union([a, b, c,    e, f, g]) => 0,
      union([      c,       f   ]) => 1,
      union([a,    c, d, e,    g]) => 2,
      union([a,    c, d,    f, g]) => 3,
      union([   b, c, d,    f   ]) => 4,
      union([a, b,    d,    f, g]) => 5,
      union([a, b,    d, e, f, g]) => 6,
      union([a,    c,       f   ]) => 7,
      union([a, b, c, d, e, f, g]) => 8,
      union([a, b, c, d,    f, g]) => 9
    }
  end

  def union(segments) do
    Enum.reduce(segments, &MapSet.union/2)
  end

  def diff(main, subs) do
    Enum.reduce(subs, main, fn sub, acc -> MapSet.difference(acc, sub) end)
  end

  def segments_occuring_n_times(patterns, n) do
    patterns
      |> Enum.flat_map(& MapSet.to_list(&1))
      |> Enum.frequencies()
      |> Enum.filter(fn {_, count} -> count == n end)
      |> Enum.map(fn {segment, _} -> segment end)
      |> MapSet.new()
  end

  def output_value({signal_patterns, output}) do
    patterns = decode_signal_patterns(signal_patterns)
    output
    |> Enum.map(& patterns[&1])
    |> Enum.reduce(fn x, acc -> acc * 10 + x end)
  end
end

input = Advent8.read_patterns("input/8.txt")
input |> Advent8.count_uniques_in_outputs() |> IO.puts()
input |> Enum.map(&Advent8.output_value/1) |> Enum.sum() |> IO.puts()
