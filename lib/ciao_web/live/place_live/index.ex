defmodule CiaoWeb.PlaceLive.Index do
  alias Ciao.{Accounts, Places, Posts}
  alias Ciao.Images.{ImageRecord, PlaceImages}
  alias Ciao.Places.Place
  alias Ciao.Repo
  alias CiaoWeb.PlaceView
  alias Ecto.Multi
  alias Phoenix.LiveView

  import Ciao
  use LiveView

  @multi Multi.new()

  @impl LiveView
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    posts = Posts.fetch_recent(user)

    socket
    |> assign(:user, user)
    |> assign(:places, Places.fetch_all_for_user(user))
    |> assign(:posts, posts)
    |> assign(:from, from(posts))
    |> assign(:new_place, nil)
    |> assign(:image_changeset, ImageRecord.image_changeset())
    |> allow_upload(:place_pic,
      accept: ~w[.jpg .jpeg .png .gif],
      max_file_size: 10_000_000,
      max_entries: 1,
      auto_upload: true
    )
    |> ok()
  end

  defp from([_ | _] = posts) do
    [p | _] = Enum.reverse(posts)

    p.inserted_at
  end

  defp from([]), do: Timex.now()

  @impl LiveView
  def render(assigns), do: PlaceView.render("index.html", assigns)

  @impl LiveView
  def handle_event("toggle_form", params, %{assigns: %{new_place: nil}} = socket) do
    socket
    |> assign(:new_place, Place.place_changeset())
    |> noreply()
  end

  def handle_event("toggle_form", _, socket) do
    socket
    |> assign(:new_place, nil)
    |> noreply()
  end

  defp display_image(%{place_pics: [_ | _] = pics}) do
    [i | _] = Enum.reverse(pics)
    PlaceView.display_image(i, "200x200")
  end

  defp display_image(_), do: ""

  def handle_event("validate_image", _params, socket) do
    socket
    |> noreply()
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    socket
    |> cancel_upload(:place_pic, ref)
    |> noreply()
  end

  def handle_event(
        "create_place",
        %{"place" => params},
        %{assigns: %{user: user, uploads: uploads}} = socket
      ) do
    @multi
    |> Multi.run(:place, fn _, _ -> Places.create_place(params, user) end)
    |> Multi.run(:insert_image, fn _, %{place: place} ->
      consume_uploaded_entries(socket, :place_pic, fn %{path: path}, _entry ->
        {:ok, %{size: size}} = File.stat(path)
        %{data: File.read!(path), size: size}
        PlaceImages.create_image(user, File.read!(path), place, size)
      end)
      |> ok()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{insert_image: image, place: place}} ->
        place = place |> Repo.preload(:place_pics)

        socket
        |> assign(:place, place)
        |> assign(:place_changeset, nil)
        |> noreply()

      _ ->
        socket
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
