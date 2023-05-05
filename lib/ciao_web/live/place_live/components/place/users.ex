defmodule Ciao.PlaceLive.UsersComponent do
  @moduledoc "Lists all users in a place"

  alias Ciao.Accounts
  alias Ciao.Places
  import Ciao

  import Phoenix.LiveView.Helpers
  use Phoenix.LiveComponent

  def update(assigns, socket) do
    socket
    |> assign(:place, assigns.place)
    |> assign(:users, Places.fetch_users_for_place(assigns.place))
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div>
        <h3>Current users</h3>
        <ul>
            <%= for user <- @users do %>
                <li class="f-row justify-between">
                    <span><%= user.email %></span>
                    <span> <i><%= current_role(user, @place) %></i></span>
                </li>
            <% end %>
        </ul>
    </div>
    """
  end

  defp current_role(%{user_relations: roles}, %{id: id}) do
    roles |> Enum.find(&(&1.place_id == id)) |> Map.get(:role)
  end
end
