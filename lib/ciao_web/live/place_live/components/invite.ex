defmodule Ciao.PlaceLive.InviteComponent do
  @moduledoc "Forms for inviting users"

  alias Ciao.Accounts
  alias Ciao.Places

  import Phoenix.HTML.Form
  import Ciao

  import Phoenix.LiveView.Helpers

  use Phoenix.LiveComponent

  def update(assigns, socket) do
    socket
    |> assign(:place, assigns.place)
    |> assign(:user, assigns.user)
    |> assign(:visible, false)
    |> assign(:users, [])
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if @visible do%>
        <%= text_input :user, :search, phx_keyup: "search", phx_target: @myself %>
        <%= for usr <- @users do %>
          <%= usr.email %>
          <button phx-click={:add_user} phx-value-user={usr.email} phx-value-role={"viewer"} phx-target={@myself}>add viewer</button>
          <button phx-click={:add_user} phx-value-user={usr.email} phx-value-role={"contributor"} phx-target={@myself}>add contributor</button>
        <% end %>
      <% else %>
        <button phx-click={:toggle_form} phx-target={@myself}>Invite</button>
      <% end %>
    </div>
    """
  end

  def handle_event("toggle_form", _, %{assigns: %{visible: visible}} = socket) do
    socket
    |> assign(:visible, !visible)
    |> noreply()
  end

  def handle_event("search", %{"value" => term}, %{assigns: %{place: place}} = socket) do
    case Accounts.find_accounts(term, place) do
      {:ok, res} ->
        socket
        |> assign(:users, res)
        |> noreply()

      res ->
        socket
        |> assign(:users, res)
        |> noreply()
    end
  end

  def handle_event(
        "add_user",
        %{"role" => role, "user" => invitee},
        %{assigns: %{user: user, place: place}} = socket
      ) do
    Places.add_user(user.id, place.id, invitee, role)

    socket
    # |> put_flash("successfully invited user")
    |> assign(:visible, false)
    |> noreply()
  end
end
