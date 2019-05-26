defmodule Identicon do
  def main input do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("images/#{input}.png", image)
  end

  def draw_image %Identicon.Image{ color: color, pixel_map: pixel_map } do
    # :egd is the Erlang graphic drawer 
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({ start, stop }) -> 
      :egd.filledRectangle(image, start, stop, fill)
    end
    # creates image with format .png, etc.
    :egd.render(image)
  end

  def build_pixel_map %Identicon.Image{ grid: grid } = image do
    # Iterate over all the tuples in the grid ( to get coordinates )
   pixel_map = Enum.map grid, fn({ _code, index }) -> 
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = { horizontal, vertical }
      bottom_right = { horizontal + 50, vertical + 50 }

      { top_left, bottom_right }
    end

    %Identicon.Image{ image | pixel_map: pixel_map }
  end

  def filter_odd_squares %Identicon.Image{ grid: grid } = image do
    # filter the odd squares ( Even squares will remain )
    grid  = Enum.filter grid, fn({ code, _index }) -> 
      rem(code, 2) == 0
    end

    %Identicon.Image{ image | grid: grid }
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
