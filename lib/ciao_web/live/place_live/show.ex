defmodule CiaoWeb.PlaceLive.Show do
  alias Ciao.{Accounts, Places, Posts}
  alias Ciao.Posts.Post
  alias Ciao.Accounts.Authorization
  alias CiaoWeb.PlaceView

  alias Phoenix.LiveView

  import Ciao
  use LiveView

  @all_authorized_users ~w[owner contributor viewer]
  @authorized_to_post ~w[owner contributor]

  @impl LiveView
  def mount(params, session, socket) do
    Authorization.authorize_user(socket, session, params, @all_authorized_users, &load_place/3)
  end

  defp load_place(%{assigns: %{place: place}} = socket, _session, _params) do
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
  end

  defp changeset_if_user_can_post(socket), do: assign(socket, :changeset, false)

  @impl LiveView
  def render(assigns), do: PlaceView.render("show.html", assigns)

  @impl LiveView
  def handle_event("create_post", %{"post" => params}, %{assigns: %{user: user}} = socket) do
    user
    |> Posts.create_post(params)
    |> case do
      {:ok, %Post{} = post} ->
        IO.inspect(post, label: "WOW")
        posts = [post] ++ socket.assigns.posts

        socket
        |> put_flash(:success, "Post created and saved to place!")
        |> assign(:posts, posts)
        |> noreply

      {:error, _} ->
        socket
        |> put_flash(:error, "There was a problem saving this post, please try again.")
        |> noreply()
    end
  end
end
