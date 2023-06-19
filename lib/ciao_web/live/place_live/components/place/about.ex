defmodule Ciao.PlaceLive.AboutComponent do
  @moduledoc "Show/update info about the place"
  alias Ciao.Places.Place
  alias Ciao.Images.{ImageRecord, PlaceImages}
  alias Ciao.PlacesLive.Forms
  alias Ciao.Repo
  alias CiaoWeb.PlaceView
  alias Ecto.Multi
  import Ciao
  import Phoenix.LiveView.Helpers

  use Phoenix.LiveComponent

  @multi Multi.new()

  def update(assigns, socket) do
    socket
    |> assign(:user, assigns.user)
    |> assign(:place, assigns.place)
    |> assign(:relation, assigns.relation)
    |> assign(:place_changeset, nil)
    |> assign(:image_changeset, ImageRecord.image_changeset())
    |> allow_upload(:place_pic,
      accept: ~w[.jpg .jpeg .png .gif],
      max_file_size: 10_000_000,
      max_entries: 1,
      auto_upload: true
    )
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div class="f-col">
        <%= if !@place_changeset do %>
          <h1><%= @place.name %></h1>
          <div class="self-center">
            <%= display_image(@place) %>
          </div>
            <div class="info">
               <%= @place.description %>
            </div>
            <%= if @relation.role == "owner" do %>
                <div class="update">
                    <button phx-click={:toggle_form} phx-target={@myself}>Edit</button>
                </div>
            <% end %>
        <% else %>
            <Forms.place_form changeset={@place_changeset} uploads={@uploads} myself={@myself}/>
        <% end %>
    </div>
    """
  end

  defp display_image(%{place_pics: [_ | _] = pics}) do
    [i | _] = Enum.reverse(pics)
    assigns = %{}

    ~H"""
    <div class="place-pic--md">
      <%= PlaceView.display_image(i, "200x200") %>
    </div>
    """
  end

  defp display_image(_) do
    assigns = %{}

    ~H"""
      <div class='place-pic--md empty'></div>
    """
  end

  def handle_event("toggle_form", _, %{assigns: %{place_changeset: nil, place: place}} = socket) do
    socket
    |> assign(:place_changeset, Place.update_changeset(place))
    |> noreply()
  end

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
        %{assigns: %{user: user, uploads: uploads, place: place}} = socket
      ) do
    @multi
    |> Multi.update(:place, Place.update_changeset(place, params))
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
end
