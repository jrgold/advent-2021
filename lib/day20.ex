defmodule Image do
  defstruct [:data, :border, :x_max, :y_max]
end

defmodule Advent20 do
  def read_image_stuff(file_name) do
    [algorithm, image] =
      File.read!(file_name)
      |> String.split("\n\n")

    algorithm = algorithm
      |> String.graphemes()
      |> Enum.with_index()
      |> Map.new(fn {val, index} -> {index, if val == "#" do 1 else 0 end} end)

    image = image
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        String.graphemes(line)
        |> Enum.with_index(fn char, x -> {{x, y}, if char == "#" do 1 else 0 end} end)
      end)
      |> Map.new()

    x_max = image |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.max()
    y_max = image |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.max()

    {algorithm, %Image{data: image, border: 0, x_max: x_max, y_max: y_max}}
  end

  def iterate(algorithm, %Image{data: data, border: border, x_max: x_max, y_max: y_max}) do
    data = for new_x <- 0..x_max+4, new_y <- 0..y_max+4, do: (
      bits = for y <- -1..1, x <- -1..1, do:
        Map.get(data, {new_x - 2 + x, new_y - 2 + y}, border)
      index = bits |> Enum.reduce(fn bit, acc -> acc * 2 + bit end)
      {{new_x, new_y}, algorithm[index]}
    )
    new_border_index = 0..8 |> Enum.map(fn _ -> border end) |> Enum.reduce(fn bit, acc -> acc * 2 + bit end)
    %Image{
      data: Map.new(data),
      border: algorithm[new_border_index],
      x_max: x_max + 4,
      y_max: y_max + 4
    }
  end

  def pixels_lit_after_n_iterations(algorithm, image, n) do
    Stream.iterate(image, fn image -> iterate(algorithm, image) end)
    |> Stream.drop(n)
    |> Enum.at(0)
    |> then(& &1.data)
    |> Map.values()
    |> Enum.sum()
  end
end

{algorithm, image} = Advent20.read_image_stuff("input/20.txt")
Advent20.pixels_lit_after_n_iterations(algorithm, image, 50) |> IO.inspect()
