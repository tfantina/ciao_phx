defmodule CiaoWeb.PlaceLive.Show do
  alias Ciao.{Accounts, Places, Posts}
  alias Ciao.Images.{ImageRecord, PostImages}
  alias Ciao.Posts.Post
  alias Ciao.Accounts.Authorization
  alias CiaoWeb.PlaceView
  alias Ecto.{Multi, UUID}

  alias Phoenix.LiveView
  alias Ciao.Repo

  import Ciao
  import Ciao.EctoSupport
  use LiveView

  @all_authorized_users ~w[owner contributor viewer]
  @authorized_to_post ~w[owner contributor]
  @multi Multi.new()

  @impl LiveView
  def mount(params, session, socket) do
    Authorization.authorize_user(socket, session, params, @all_authorized_users, &load_place/3)
  end

  defp load_place(%{assigns: %{place: place}} = socket, _session, _params) do
    IO.inspect(label: "OK SURE")

    socket
    |> assign(:posts, Posts.fetch_all_for_place(place))
    |> changeset_if_user_can_post()
    |> assign(:place, place)
    |> ok()
  end

  defp changeset_if_user_can_post(%{assigns: %{user_relation: %{role: role}}} = socket)
       when role in @authorized_to_post do
    socket
    |> assign(:changeset, Post.changeset())
    |> assign(:image_changeset, ImageRecord.image_changeset())
    |> allow_upload(:images,
      accept: ~w[.jpg .jpeg .png .gif],
      max_file_size: 10_000_000,
      max_entries: 10,
      auto_upload: true
    )
  end

  defp changeset_if_user_can_post(socket), do: assign(socket, :changeset, false)

  @impl LiveView
  def render(assigns), do: PlaceView.render("show.html", assigns)

  @impl LiveView
  def handle_event(
        "create_post",
        %{"post" => params},
        %{assigns: %{user: user, uploads: uploads}} = socket
      ) do
    @multi
    |> Multi.run(:post, fn _, _ -> Posts.create_post(user, params) end)
    |> Multi.run(:insert_images, fn _, %{post: post} ->
      consume_uploaded_entries(socket, :images, fn %{path: path}, _entry ->
        {:ok, %{size: size}} = File.stat(path)
        IO.inspect(label: "OK ")
        %{data: File.read!(path), size: size}
        Posts.upload_image(user, File.read!(path), post, size)
      end)
      |> ok()
    end)
    |> Repo.transaction()
    |> IO.inspect(label: "THIS IS SIMPLE")
    |> case do
      {:ok, %{insert_images: images, post: post}} ->
        socket
        |> noreply()

        posts = [post] ++ socket.assigns.posts

        socket
        |> put_flash(:success, "Post created and saved to place!")
        |> assign(:posts, posts)
        |> noreply

      _ ->
        socket
        |> put_flash(:error, "There was a problem saving this post, please try again.")
        |> noreply()
    end
  end

  def handle_event("validate_image", _params, socket) do
    socket
    |> noreply()
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    socket
    |> cancel_upload(:images, ref)
    |> noreply()
  end
end
