defmodule Ciao.PlacesLive.PostFormComponent do
  @moduledoc false
  alias Ciao.Accounts
  alias Ciao.Images.{ImageRecord, PostImages}
  alias Ciao.Posts
  alias Ciao.Posts.Post
  alias Ciao.Repo
  alias Ecto.Multi

  import Phoenix.HTML.Form
  import Ciao

  use Phoenix.LiveComponent

  @multi Multi.new()

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(:post, assigns.post)
    |> assign(:changeset, Post.changeset_edit(assigns.post, %{}))
    |> assign(:image_changeset, ImageRecord.image_changeset())
    |> allow_upload(:images,
      accept: ~w[.jpg .jpeg .png .gif],
      max_file_size: 10_000_000,
      max_entries: 10,
      auto_upload: true
    )
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div style="width: 100%">
    <div class="row">
        <%= for img <- @uploads.images.entries do %>
            <%= live_img_preview img %>
            <%= img.progress %>
            <progress value={img.progress} max="100"><%= img.progress %>%</progress>
            <%= for err <- upload_errors(@uploads.images, img) do  %>
                <div class="error">
                </div>
            <% end %>
            <button phx-click="cancel-upload" phx-value-ref={img.ref} phx-target={@myself} aria-label="cancel">&times;</button>

        <% end %>
        <form id="photos" phx-change="validate_image" phx-target={@myself}>
            <%= live_file_input @uploads.images %>
        </form>
     </div>
     <div class="row">
      <.form for={@changeset} let={f} phx-submit="post" phx-update="update" phx-target={@myself} >
          <%= textarea f, :body, phx_hook: "textEditorHook", id: "post-body" %>
          <%= submit "Post" %>
      </.form>
    </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate_image", _params, socket) do
    socket
    |> noreply()
  end

  def handle_event(
        "post",
        %{"post" => params},
        %{assigns: %{post: post, uploads: uploads}} = socket
      ) do
    @multi
    |> Multi.put(:user, Accounts.get_user!(post.user_id))
    |> Multi.run(:post, fn _, _ -> Posts.update_post(post, params) end)
    |> Multi.run(:insert_images, fn _, %{user: user, post: post} ->
      consume_uploaded_entries(socket, :images, fn %{path: path}, _entry ->
        {:ok, %{size: size}} = File.stat(path)
        %{data: File.read!(path), size: size}
        PostImages.create_image(user, File.read!(path), post, size)
      end)
      |> ok()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{insert_images: images, post: post}} ->
        post =
          post
          |> Repo.preload(images: [:image_variants])

        socket
        |> put_flash(:success, "Post saved!")
        |> assign(:post, post)
        |> noreply()

      _ ->
        socket
        |> put_flash(:error, "There was a problem saving this post, please try again.")
        |> noreply()
    end
  end
end
