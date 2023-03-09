defmodule Ciao.PlacesLive.PostComponent do
  alias Ciao.Posts
  alias Ciao.Posts.Comment
  alias Ciao.Repo
  alias CiaoWeb.PlaceView

  import Ciao
  use Phoenix.HTML
  use Phoenix.LiveComponent

  def update(assigns, socket) do
    socket
    |> assign(:post, assigns.post)
    |> assign(:user, assigns.user)
    |> assign(:comment_changeset, Comment.comment_changeset())
    |> assign(:show_comments, false)
    |> ok()
  end

  def render(assigns) do
    ~H"""
      <div class="post d-flex f-col">
      <div class="content row">
        <%= if @post.images != [] do %>
          <%= for img <- @post.images do %>
            <%= PlaceView.display_image(img) %>
          <% end %>
        <% end %>
          <%= @post.body %>
        </div>
        <div class="footer">
          <div class="row d-flex f-row justify-between">
            <span><%= @post.user.email %> - <%= Timex.from_now(@post.inserted_at) %> ago</span>
            <%= link to: "#", phx_click: "toggle_comments", phx_target: @myself do %>
              <%= length(@post.comments) %> Comments
            <% end %>
          </div>
          <%= if @show_comments do %>
            <div class="comments">
              <div class="row">
                <.form for={@comment_changeset} let={f} phx-submit="insert_comment" phx-target={@myself}>
                  <%= text_input f, :body %>
                </.form>
              </div>
              <div class="d-flex f-col">
              <%= for comment <- @post.comments do %>
                <div class="comment">
                  <%= comment.body %>
                </div>
              <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    """
  end

  def handle_event("toggle_comments", _params, %{assigns: %{show_comments: true}} = socket) do
    socket
    |> assign(:show_comments, false)
    |> noreply()
  end

  def handle_event("toggle_comments", _params, socket) do
    socket
    |> assign(:show_comments, true)
    |> noreply()
  end

  def handle_event(
        "insert_comment",
        %{"comment" => params},
        %{assigns: %{user: user, post: post}} = socket
      ) do
    params
    |> Map.merge(%{"user_id" => user.id, "post_id" => post.id})
    |> Comment.comment_changeset()
    |> Repo.insert()
    |> case do
      {:ok, _} ->
        socket
        |> assign(:post, Posts.get(post.id) |> Repo.preload([:comments, :user]))
        |> put_flash(:success, "Commented!")
        |> noreply()

      _ ->
        socket
        |> put_flash(:error, "Problem commenting please try again.")
        |> noreply()
    end
  end
end
