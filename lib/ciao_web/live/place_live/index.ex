defmodule CiaoWeb.PlaceLive.Index do
  alias Ciao.{Accounts, Places}
  alias CiaoWeb.PlaceView
  alias Ciao.Places.Place
  alias Phoenix.LiveView
  import Ciao
  use LiveView

  @impl LiveView
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    socket
    |> assign(:user, user)
    |> assign(:places, Places.fetch_all_for_user(user))
    |> assign(:new_changeset, Place.place_changeset())
    |> ok()
  end

  @impl LiveView
  def render(assigns), do: PlaceView.render("index.html", assigns)

  @impl LiveView
  def handle_event("create_place", %{"place" => params}, %{assigns: %{user: user}} = socket) do
    params
    |> Places.create_place(user)
    |> case do
      {:ok, %{place: place}} ->
        socket
        |> assign(:places, socket.assigns.places ++ [place])
        |> put_flash(:success, "#{place.name} created successfully")
        |> noreply()

      {:error, _} ->
        socket
        |> put_flash(:error, "There was a problem saving this place, please try again")
        |> noreply()
    end
  end
end
