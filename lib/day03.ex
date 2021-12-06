defmodule Day03 do
  def read_report(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line -> line
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def transpose(matrix) do
    Utils.transpose(matrix)
  end

  def bit_list_to_int(bits) do
    Enum.reduce(bits, fn b, acc -> acc * 2 + b end)
  end

  def power(report) do
    gamma_bits =
      report
      |> transpose
      |> Enum.map(fn bit_values -> bit_values
        |> Enum.group_by(&(&1))
        |> Enum.reduce(fn {b1, bs1}, {b2, bs2} ->
          if Enum.count(bs1) > Enum.count(bs2) do b1 else b2 end
        end)
      end)
    epsilon_bits = Enum.map(gamma_bits, &(1 - &1))
    bit_list_to_int(gamma_bits) * bit_list_to_int(epsilon_bits)
  end

  def life_support(report) do
    oxygen_criteria = fn bits ->
      zeros = Enum.count(bits, &(&1 == 0))
      ones  = Enum.count(bits, &(&1 == 1))
      cond do
        zeros < ones -> 1
        zeros > ones -> 0
        true         -> 1
      end
    end
    co2_criteria = fn bits ->
      zeros = Enum.count(bits, &(&1 == 0))
      ones  = Enum.count(bits, &(&1 == 1))
      cond do
        zeros < ones -> 0
        zeros > ones -> 1
        true         -> 0
      end
    end

    oxygen = execute_criteria(report, oxygen_criteria)
    co2    = execute_criteria(report, co2_criteria)
    bit_list_to_int(oxygen) * bit_list_to_int(co2)
  end

  def execute_criteria(report, criteria) do
    bit =
      report
      |> Enum.map(&List.first/1)
      |> criteria.()
    remaining =
      report
      |> Enum.filter(&(List.first(&1) == bit))
    case remaining do
      [result]  -> result
      remaining ->
        next_bits = Enum.map(remaining, &(Enum.drop(&1, 1)))
        [bit | execute_criteria(next_bits, criteria)]
    end
  end
end

input = Day03.read_report("input/3.txt")
input |> Day03.power() |> IO.puts()
input |> Day03.life_support() |> IO.puts()
