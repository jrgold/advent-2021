defmodule Advent14 do
  def read_instructions(file_name) do
    [template, rules] = file_name
      |> File.read!()
      |> String.split("\n\n")

    rules = rules
      |> String.split("\n")
      |> Enum.map(fn line ->
        [pair, result] = String.split(line, " -> ")
        {pair |> String.graphemes() |> List.to_tuple(), result}
      end)
      |> Map.new()

    {String.graphemes(template), rules}
  end

  def polymerize_once(template, rules) do
    Enum.chunk_every(template, 2, 1)
    |> Enum.flat_map(fn chunk ->
      case chunk do
        [a, b] -> [a, Map.get(rules, {a, b})]
        [a] -> [a]
      end
    end)
  end

  def polymerize({template, rules}, iterations) do
    Stream.iterate(template, & polymerize_once(&1, rules)) |> Enum.at(iterations)
  end

  def difference_in_min_max_quantities(quantities) do
    {min, max} =
      quantities
      |> Enum.map(fn {_, count} -> count end)
      |> Enum.min_max()
    max - min
  end

  # Think of polymerization as something that happens to a single character,
  # which might be followed by another character. So if we're polymerizing "ae":
  #
  #     a   e       ae
  #    / \ / \
  #   a   c   e     ace
  #   |\ /|\ /|
  #   a b c d e     abcde
  #
  # What we're actually doing is
  #   - polymerizing the "a" (which is followed by an "e", stylized "Ae" below)
  #   - then polymerizing the "e" (stylized "E" below)
  #
  #   Ae          E     AE
  #   |   \       |
  #   Ac    Ce    E     ACE
  #   | \   | \   |
  #   Ab Bc Cd De E     ABCDE
  #   |  |  |  |  |
  #   A  B  C  D  E
  #
  # We build a map representing every node in the polymerization tree:
  #
  #             Ae,2             E,2
  #             ABCD              E
  #           /      \            |
  #      Ac,1         Ce,1       E,1
  #       AB           CD         E
  #      /  \         /  \        |
  #   Ab,0  Bc,0   Cd,0  De,0    E,0
  #    A     B      C      D      E
  #
  # Where the keys are (letter and follower?, iterations of polymerization)
  # and the values are the frequency map of letters of the n-polymerization of that letter.
  # We call each of these mappings an n-polymerization.
  def populate_n_polymerizations(
    rules,
    {[single_char], iterations} = char_and_iterations,
    n_polymerizations
  ) do
    # Calculate the full chain of n-polymerizations for a single character even though we don't really need to
    if iterations == 0 do
      Map.put(n_polymerizations, char_and_iterations, %{single_char => 1})
    else
      case n_polymerizations[char_and_iterations] do
        nil ->
          n_polymerizations = populate_n_polymerizations(rules, {[single_char], iterations - 1}, n_polymerizations)
          Map.put(
            n_polymerizations,
            char_and_iterations,
            n_polymerizations[{[single_char], iterations - 1}]
          )
        _ -> n_polymerizations
      end
    end
  end

  def populate_n_polymerizations(
    rules,
    {[main_char, follower_char], iterations} = char_with_follower_and_iterations,
    n_polymerizations
  ) do
    if iterations == 0 do
      Map.put(
        n_polymerizations,
        char_with_follower_and_iterations,
        %{main_char => 1}
      )
    else
      case Map.get(n_polymerizations, char_with_follower_and_iterations) do
        nil ->
          new_middle_char = rules[{main_char, follower_char}]
          left_half = {[main_char, new_middle_char], iterations - 1}
          right_half = {[new_middle_char, follower_char], iterations - 1}
          # Calculate sub-polymerizations
          n_polymerizations = populate_n_polymerizations(rules, left_half, n_polymerizations)
          n_polymerizations = populate_n_polymerizations(rules, right_half, n_polymerizations)
          # Merge sub-polymerizations
          quantities = Map.merge(
            n_polymerizations[left_half],
            n_polymerizations[right_half],
            fn _, count1, count2 -> count1 + count2
          end)
          Map.put(n_polymerizations, char_with_follower_and_iterations, quantities)
        # Quantities for this pair with this many iterations have already been calculated
        _ -> n_polymerizations
      end
    end
  end

  def quantities_after_polymerization({template, rules}, iterations) do
    # Folding rather than mapping to reuse already-calculated n-polymerizations
    n_polymerizations = Enum.reduce(
      Enum.chunk_every(template, 2, 1),
      %{},
      fn char_with_maybe_follower, n_polymerizations ->
        populate_n_polymerizations(rules, {char_with_maybe_follower, iterations}, n_polymerizations)
      end
    )

    # Merge the n-polymerizations of each letter in our template
    Enum.chunk_every(template, 2, 1)
    |> Enum.map(fn char_with_maybe_follower -> n_polymerizations[{char_with_maybe_follower, iterations}] end)
    |> Enum.reduce(
      fn quantities1, quantities2 -> Map.merge(quantities1, quantities2, fn _, c1, c2 -> c1 + c2 end) end
    )
  end
end

input = Advent14.read_instructions("input/14.txt")
input
  |> Advent14.polymerize(10)
  |> Enum.frequencies()
  |> Advent14.difference_in_min_max_quantities()
  |> IO.puts()
input
  |> Advent14.quantities_after_polymerization(40)
  |> Advent14.difference_in_min_max_quantities()
  |> IO.inspect()
