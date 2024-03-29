defmodule Ciao.PlaceLive.UsersComponent do
  @moduledoc "Lists all users in a place"

  alias Ciao.Accounts
  alias Ciao.Places
  alias Ciao.Places.UserRelation
  alias Ciao.Repo
  import Ciao

  import Phoenix.LiveView.Helpers
  use Phoenix.LiveComponent

  def render(assigns) do
    assigns =
      assigns
      |> assign_new(:users, fn _ -> Places.fetch_users_for_place(assigns.place) end)
      |> assign_new(:edit_user_role, fn _ -> %{} end)

    ~H"""
    <div>   
        <h3>Current users</h3>
        <ul>
            <%= for user <- @users do %>
                <li class="f-row">
                  <div class="col-7">
                    <%= user.email %>
                  </div>
                  <div class="col-4">
                    <%= current_role(user, @place) %>
                  </div>
                    <%= if @relation.role == "owner" && user.id != @user.id do %> 
                      <div class="col-1">
                       <a phx-click={:toggle_form} phx-target={@myself} phx-value-user-id={user.id}> 
                          <Heroicons.LiveView.icon name="pencil-square" />
                       </a>
                      </div>
                    <% end %>
                </li>
                  <%= if open_user(@edit_user_role, user) do %>
                      <div class="f-row justify-content-between">
                        <div class="col-5">
                          <button phx-click={:change_user} phx-value-role={"viewer"} phx-target={@myself} class="btn-sm--tertiary">set viewer</button>
                        </div>
                        <div class="col-5">
                          <button phx-click={:change_user} phx-value-role={"contributor"} phx-target={@myself} class="btn-sm--tertiary">set contributor</button>
                        </div>
                      </div>
                    <% end %>
            <% end %>
        </ul>
    </div>
    """
  end

  defp current_role(%{user_relations: roles}, %{id: id}) do
    roles |> Enum.find(&(&1.place_id == id)) |> Map.get(:role)
  end

  def handle_event("toggle_form", %{"user-id" => id}, %{assigns: %{place: place}} = socket) do
    role = Accounts.get_user_role(id, place.id)

    socket
    |> assign(:edit_user_role, role)
    |> noreply()
  end

  def handle_event(
        "change_user",
        %{"role" => role},
        %{assigns: %{edit_user_role: user_role}} = socket
      ) do
    user_role
    |> UserRelation.changeset_update(%{role: role})
    |> Repo.update()
    |> case do
      {:ok, _} ->
        socket
        |> put_flash(:success, "User Updated")
        |> assign(:users, Places.fetch_users_for_place(socket.assigns.place))
        |> assign(:edit_user_role, %{})
        |> noreply()

      _ ->
        socket
        |> put_flash(:error, "User update failed")
        |> noreply()
    end
  end

  defp open_user(%{user_id: id}, %{id: usr_id}),
    do: id == usr_id

  defp open_user(_, _), do: false
end
