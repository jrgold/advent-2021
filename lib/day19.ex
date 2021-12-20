defmodule Advent19 do
  def read_scanners(file_name) do
    File.read!(file_name)
    |> String.split("\n\n")
    |> Enum.map(fn section ->
      String.split(section, "\n")
      |> Stream.drop(1)
      |> Enum.map(fn line ->
        String.split(line, ",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
    end)
  end

  def point_orientations({x, y, z}) do
    [
      {x, y, z},
      {x, -z, y},
      {x, -y, -z},
      {x, z, -y},
      {-x, -y, z},
      {-x, z, y},
      {-x, y, -z},
      {-x, -z, -y},

      {y, -x, z},
      {y, -z, -x},
      {y, x, -z},
      {y, z, x},
      {-y, x, z},
      {-y, z, -x},
      {-y, -x, -z},
      {-y, -z, x},

      {z, y, -x},
      {z, x, y},
      {z, -y, x},
      {z, -x, -y},
      {-z, -y, -x},
      {-z, -x, y},
      {-z, y, x},
      {-z, x, -y},
    ]
  end

  # scanner 4:

  def new_beacons_if_scanner_fits_into_beacon_space(beacon_space, scanner_beacons) do
    orientations = scanner_beacons
      |> Enum.map(&point_orientations/1)
      |> Utils.transpose()

   maybe_new_matching_beacons = orientations
      |> Stream.map(& fit_oriented_beacon_into_beacon_space(beacon_space, &1))
      |> Stream.filter(& &1 != nil)
      |> Stream.take(1)
      |> Enum.to_list()

    case maybe_new_matching_beacons do
      [{beacons, scanner_position}] ->
        {MapSet.union(beacon_space, MapSet.new(beacons)), scanner_position}
      _ -> nil
    end
  end

  def fit_oriented_beacon_into_beacon_space(beacon_space, oriented_beacons) do
    # TODO: we can limit the beacon space by distance
    maybe_matching_beacons = oriented_beacons
      |> Stream.flat_map(fn beacon_from_scanner ->
        beacon_space |> MapSet.to_list() |> Stream.map(& {beacon_from_scanner, &1})
      end)
      |> Stream.filter(fn {reference_beacon_from_new_scanner, maybe_matching_beacon_in_space} ->
        translation = sub_coordinates(maybe_matching_beacon_in_space, reference_beacon_from_new_scanner)
        matching_beacons = oriented_beacons
          |> Enum.count(fn new_beacon ->
            translated_beacon = add_coordinates(new_beacon, translation)
            MapSet.member?(beacon_space, translated_beacon)
          end)
        # IO.inspect(matching_beacons)
        matching_beacons >= 12
      end)
      |> Stream.take(1)
      |> Enum.to_list()
    case maybe_matching_beacons do
      [{scanner_beacon, space_beacon}] ->
        translation = sub_coordinates(space_beacon, scanner_beacon) # position of scanner
        {
          oriented_beacons |> Enum.map(& add_coordinates(&1, translation)),
          translation
        }
      _ -> nil
    end
  end

  def add_coordinates({x1, y1, z1}, {x2, y2, z2}) do
    {x1 + x2, y1 + y2, z1 + z2}
  end

  def sub_coordinates({x1, y1, z1}, {x2, y2, z2}) do
    {x1 - x2, y1 - y2, z1 - z2}
  end

  def build_beacon_space([scanner0 | scanners]) do
    build_beacon_space(MapSet.new(scanner0), [{0, 0, 0}], [], scanners)
  end

  def build_beacon_space(beacon_space, scanner_positions, [], []), do: {beacon_space, scanner_positions}
  def build_beacon_space(beacon_space, scanner_positions, scanners_not_matching, [scanner_to_check | unchecked_scanners]) do
    case new_beacons_if_scanner_fits_into_beacon_space(beacon_space, scanner_to_check) do
      nil -> build_beacon_space(beacon_space, scanner_positions, [scanner_to_check | scanners_not_matching], unchecked_scanners)
      {new_beacon_space, scanner_position} -> build_beacon_space(
        new_beacon_space,
        [scanner_position | scanner_positions],
        [],
        scanners_not_matching ++ unchecked_scanners
      )
    end
  end

  def largest_manhattan_distance(scanner_positions) do
    scanner_positions
    |> pairs()
    |> Enum.map(fn {{x1, y1, z1}, {x2 , y2, z2}} -> abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2) end)
    |> Enum.max()
  end

  def pairs(list) do
    case list do
      [_] -> []
      [x | xs] -> Enum.map(xs, & {x, &1}) ++ pairs(xs)
    end
  end
end

input = Advent19.read_scanners("input/19.txt")
{beacon_space, scanner_positions} = Advent19.build_beacon_space(input)
beacon_space |> Enum.count() |> IO.inspect()
scanner_positions |> Advent19.largest_manhattan_distance() |> IO.inspect()
# beacon_space = MapSet.new([
#   {-618, -824, -621},
#   {-537, -823, -458},
#   {-447, -329, 318},
#   {404, -588, -901}
# ])
# beacons = [
#   {686, 422, 578},
#   {605, 423, 415},
#   {515, 917, -361},
#   {-336, 658, 858}
# ]
# beacon_space = MapSet.new(Enum.at(input, 0))
# beacon_space = Advent19.new_beacons_if_scanner_fits_into_beacon_space(beacon_space, Enum.at(input, 1))
# beacon_space = Advent19.new_beacons_if_scanner_fits_into_beacon_space(beacon_space, Enum.at(input, 4))
# beacon_space = Advent19.new_beacons_if_scanner_fits_into_beacon_space(beacon_space, Enum.at(input, 2))
# beacon_space = Advent19.new_beacons_if_scanner_fits_into_beacon_space(beacon_space, Enum.at(input, 3))
# beacon_space |> Enum.sort() |> IO.inspect()
# beacon_space |> IO.inspect()

# beacon_space_1 = MapSet.new([
#   {-739, -1745, 668},
#   {-687, -1600, 576},
#   {-661, -816, -575},
#   {-635, -1737, 486},
#   {-618, -824, -621},
#   {-601, -1648, -643},
#   {-537, -823, -458},
#   {-518, -1681, -600},
#   {-499, -1607, -770},
#   {-485, -357, 347},
#   {-447, -329, 318},
#   {-345, -311, 381},
#   {-27, -1108, -65},
#   {390, -675, -793},
#   {396, -1931, -563},
#   {404, -588, -901},
#   {408, -1815, 803},
#   {423, -701, 434},
#   {432, -2009, 850},
#   {459, -707, 401},
#   {497, -1838, -617},
#   {528, -643, 409},
#   {534, -1912, 768},
#   {544, -627, -890},
#   {568, -2007, -577}
# ])

# beacon_space = Advent19.new_beacons_if_scanner_fits_into_beacon_space(beacon_space_1, Enum.at(input, 4))
# IO.inspect(beacon_space)

# overlap_1_4 = [
#   {459,-707,401},
#   {-739,-1745,668},
#   {-485,-357,347},
#   {432,-2009,850},
#   {528,-643,409},
#   {423,-701,434},
#   {-345,-311,381},
#   {408,-1815,803},
#   {534,-1912,768},
#   {-687,-1600,576},
#   {-447,-329,318},
#   {-635,-1737,486}
# ]
# pos_1 = {68,-1246,-43}
# pos_4 = {-20,-1133,1061}
# Enum.map(overlap_1_4, & Advent19.sub_coordinates(&1, pos_1)) |> IO.inspect()
# Enum.map(overlap_1_4, & Advent19.sub_coordinates(&1, pos_4)) |> Enum.sort() |> IO.inspect()
