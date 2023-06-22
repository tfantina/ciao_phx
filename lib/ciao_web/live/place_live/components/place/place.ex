defmodule Ciao.PlacesLive.Place do
  alias CiaoWeb.PlaceView
  import Phoenix.HTML.Link, only: [link: 2]
  use Phoenix.Component

  def line(assigns) do
    ~H"""
    <li class="row align-center">
        <%= display_image(@place) %>
        <a href={"/app/places/#{place_slug(@place)}"}><%= @place.name %></a>
    </li>
    """
  end

  defp display_image(%{place_pics: [_ | _] = pics}) do
    [i | _] = Enum.reverse(pics)
    assigns = %{}

    ~H"""
    <div class="place-pic--sm"><%= PlaceView.display_image(i, "200x200") %></div>
    """
  end

  defp display_image(_) do
    assigns = %{}

    ~H"""
    <div class="place-pic--sm empty">
    </div>
    """
  end

  defp place_slug(%{slug: slug}) when not is_nil(slug), do: slug
  defp place_slug(%{id: id}), do: id
end
