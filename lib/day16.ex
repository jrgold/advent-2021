use Bitwise

defmodule Advent16 do
  def read_bits(file_name) do
    file_name
    |> File.read!()
    |> Base.decode16!()
  end

  def parse_packet(bits) do
    case bits do
      <<version::3, 4::3, rest::bitstring>> ->
        {literal, rest} = consume_literal_value(rest)
        packet = %{
          type: :literal,
          version: version,
          value: literal
        }
        {packet, rest}
      <<version::3, typeId::3, rest::bitstring>> ->
        {subpackets, rest} = consume_operator_subpackets(rest)
        packet = %{
          type: :operator,
          operator_fn: operator_fn(typeId),
          version: version,
          subpackets: subpackets
        }
        {packet, rest}
    end
  end

  def consume_literal_value(bits) do
    {sections, rest} = consume_literal_value_sections(bits, [])
    value = sections |> Enum.reduce(fn s, acc -> (acc <<< 4) + s end)
    {value, rest}
  end

  def consume_literal_value_sections(bits, sections) do
    case bits do
      <<1::1, section::4, rest::bitstring>> -> consume_literal_value_sections(rest, [section | sections])
      <<0::1, section::4, rest::bitstring>> -> {Enum.reverse([section | sections]), rest}
    end
  end

  def consume_operator_subpackets(bits) do
    case bits do
      <<0::1, length::15, subpackets::bitstring-size(length), rest::bitstring>> ->
        subpackets = Stream.unfold(subpackets, fn bits ->
          case bits do
            <<>> -> nil
            _ -> parse_packet(bits)
          end
        end)
        {Enum.to_list(subpackets), rest}
      <<1::1, count::11, rest::bitstring>> ->
        {subpackets, rest} = 1..count
          |> Enum.reduce({[], rest}, fn _, {subs, rest} ->
            {packet, rest} = parse_packet(rest)
            {[packet | subs], rest}
          end)
        {Enum.reverse(subpackets), rest}
    end
  end

  def version_total(packet) do
    if Map.has_key?(packet, :subpackets) do
      packet.version + Enum.sum(Enum.map(packet.subpackets, &version_total/1))
    else
      packet.version
    end
  end

  def operator_fn(typeId) do
    case typeId do
      0 -> fn ps -> Enum.sum(ps) end
      1 -> fn ps -> Enum.product(ps) end
      2 -> fn ps -> Enum.min(ps) end
      3 -> fn ps -> Enum.max(ps) end
      5 -> fn [a, b] -> if a > b do 1 else 0 end end
      6 -> fn [a, b] -> if a < b do 1 else 0 end end
      7 -> fn [a, b] -> if a == b do 1 else 0 end end
    end
  end

  def evaluate(packet) do
    case packet.type do
      :literal -> packet.value
      :operator -> packet.operator_fn.(Enum.map(packet.subpackets, &evaluate/1))
    end
  end
end

{packet, _} = Advent16.read_bits("input/16.txt") |> Advent16.parse_packet()
Advent16.version_total(packet) |> IO.puts()
Advent16.evaluate(packet) |> IO.puts()
