defmodule Ciao.PlacesLive.Forms do
  use CiaoWeb, :component

  def place_form(assigns) do
    ~H"""
    <.form for={@changeset} let={f}  phx-submit={"create_place"} >
        <%= label f, :name %>
        <%= text_input f, :name %>
        <%= label f, :description %>
        <%= text_input f, :description %>
        <%= label f, :slug %>
        <%= text_input f, :slug %>
        <%= submit "Create" %>
    </.form>

    """
  end
end
