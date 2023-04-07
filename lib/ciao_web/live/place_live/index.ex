defmodule CiaoWeb.PlaceLive.Index do
  alias Ciao.{Accounts, Places, Posts}
  alias CiaoWeb.PlaceView
  alias Ciao.Places.Place
  alias Phoenix.LiveView
  import Ciao
  use LiveView

  @impl LiveView
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    posts = Posts.fetch_recent(user)
    [p | _] = Enum.reverse(posts)

    socket
    |> assign(:user, user)
    |> assign(:places, Places.fetch_all_for_user(user))
    |> assign(:posts, posts)
    |> assign(:from, p.inserted_at)
    |> assign(:new_place, nil)
    |> ok()
  end

  @impl LiveView
  def render(assigns), do: PlaceView.render("index.html", assigns)

  @impl LiveView
  def handle_event("toggle_form", _, %{assigns: %{new_place: nil}} = socket) do
    socket
    |> assign(:new_place, Place.place_changeset())
    |> noreply()
  end

  def handle_event("toggle_form", _, socket) do
    socket
    |> assign(:new_place, nil)
    |> noreply()
  end

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

  def handle_event("load_more", _, %{assigns: %{from: from, posts: posts} = assigns} = socket) do
    posts = posts ++ Posts.fetch_recent(assigns.user, from: from)
    [p | _] = Enum.reverse(posts)

    socket
    |> assign(:from, p.inserted_at)
    |> assign(:posts, posts)
    |> noreply()
  end
end
