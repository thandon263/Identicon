defmodule Identicon do
  def main input do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
  end

  def filter_odd_squares %Identicon.Image{ grid: grid } = image do
    # filter the odd squares ( Even squares will remain )
  end

  def build_grid %Identicon.Image{ hex: hex } = image do
    # Pipe function will pass the argument (image) down the functions
    grid = 
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1) # This is how we pass a reference to another function
      |> List.flatten # Transform into one array / List of elements
      |> Enum.with_index # Use index to transform
    
    %Identicon.Image{ image | grid: grid }
  end

  def mirror_row row do
    # [145, 46, 200]
    [ first, second | _tail ] = row
    # [145, 46, 200, 46, 145]
    row ++ [ second, first ]
  end

  def pick_color %Identicon.Image{ hex: [r, g, b | _tail] } = image do
    %Identicon.Image{ image | color: { r, g, b }}
  end

  def hash_input input do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{ hex: hex }
  end
end
