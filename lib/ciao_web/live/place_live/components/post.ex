defmodule Ciao.PlacesLive.PostComponent do
  @moduledoc false

  alias Ciao.PlacesLive.PostFormComponent
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
    |> assign(:edit, false)
    |> ok()
  end

  def render(assigns) do
    ~H"""
      <div class="post d-flex f-col">
      <div class="header">
        <div class="row d-flex f-row justify-between">
          <span class="info-text">
            <%= @post.user.email %> - <%= Timex.from_now(@post.inserted_at) %>
          </span>
          <span>
            <%= if @user.id == @post.user_id do %>
              <a href="javascript:;" phx-click="edit" phx-target={@myself} phx-value-post-id={@post.id} class="info-text">
                Edit
              </a>
            <% end %>
          </span>
        </div>
      </div>
      <div class="content">
        <%= if @edit do %> 
          <.live_component module={PostFormComponent} post={@post} id={"edit-post-#{@post.id}"} />
        <% else %>
          <%= if @post.images != [] do %>
            <div class="glide" phx-hook="glideHook" id={"images-post-#{@post.id}"}>
              <div class="glide__track" data-glide-el="track">
                <ul class="glide__slides">
                  <%= for img <- @post.images do %>
                    <li class="glide__slide"><%= PlaceView.display_image(img, "1000x1000") %></li>
                  <% end %>
                </ul>
              </div>
              <%= if length(@post.images) > 1 do %>
                  <div class="glide__arrows f-row justify-between" data-glide-el="controls">
                    <button class="glide__arrow glide__arrow--left" data-glide-dir="<"><Heroicons.LiveView.icon name="arrow-small-left" /></button>
                    <button class="glide__arrow glide__arrow--right" data-glide-dir=">"><Heroicons.LiveView.icon name="arrow-small-right" /></button>
                  </div>
                   <div class="glide__bullets f-row justify-center" data-glide-el="controls[nav]">
                    <%=  for i <- Enum.into(0..length(@post.images) - 1, []) do %> 
                      <button class="glide__bullet" data-glide-dir={"=#{i}"}></button>
                    <% end %>
                  </div>
              <% end %>
            </div>
          <% end %>
          <div>
            <%= raw(@post.body) %>
          </div>
        <% end %>
        </div>

        <div class="footer">
          <div class="row d-flex f-row justify-between">
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

  def handle_event("edit", _, socket) do
    socket
    |> assign(:edit, !socket.assigns.edit)
    |> noreply()
  end
end
