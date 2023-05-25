defmodule Ciao.PlacesLive.Forms do
  use CiaoWeb, :component

  def place_form(assigns) do
    assigns = assign_new(assigns, :myself, fn _ -> nil end)

    ~H"""
    <div>
        <%= for img <- @uploads.place_pic.entries do %>
            <%= live_img_preview(img) %>
            <%= img.progress %>
            <progress value={img.progress} max="100"><%= img.progress %>%</progress>
            <%= for err <- upload_errors(@uploads.place_pic, img) do  %>
                <div class="error">
                </div>
            <% end %>
            <button phx-click="cancel-upload" phx-value-ref={img.ref} aria-label="cancel">&times;</button>
        <% end %>

        <form id="photo-upload" phx-change="validate_image" phx-target={@myself}>
                <%= live_file_input @uploads.place_pic %>
        </form>

        <.form for={@changeset} let={f}  phx-submit={"create_place"} phx-target={@myself} >
            <%= label f, :name %>
            <%= text_input f, :name %>
            <%= label f, :description %>
            <%= text_input f, :description %>
            <%= label f, :slug %>
            <%= text_input f, :slug %>
            <%= if @myself do %>
              <%= submit "Update" %>
            <% else %>
              <%= submit "Create" %>
            <% end %>
        </.form>
    </div>
    """
  end
end
