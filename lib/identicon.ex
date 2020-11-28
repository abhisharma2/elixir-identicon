defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  def main(username) do
    username
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(username)
  end

  def save_image(image, username) do
    File.write("#{username}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{ image | pixel_map: pixel_map }
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def pick_color(struct) do
    %Identicon.Image{ hex: [r, g, b | _tail ]} = struct
    %Identicon.Image{ struct | color: {r, g, b} }
  end

  def build_grid(struct) do
    %Identicon.Image{ hex: hex_list } = struct
    grid =
      hex_list
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{ struct | grid: grid }
  end

  def mirror_row(row) do
    [first, second | _tail ] = row
    row ++ [second, first]
  end

  def filter_odd_squares(struct) do
    %Identicon.Image{ grid: grid } = struct
    grid = Enum.filter grid, fn({hexcode, _index}) ->
      rem(hexcode, 2) == 0
    end

    %Identicon.Image{ struct | grid: grid }
  end
end
