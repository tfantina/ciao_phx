defmodule Ciao.PlacesLive.UploadComponent do
  use CiaoWeb, :component

  def uploader(assigns) do
    ~H"""
    <%= for img <- @uploads.images.entries do %>
        <%= live_img_preview img %>
        <progress value={img.progress} max="100"><%= img.progress %>%</progress>
        <%= for err <- upload_errors(@uploads.images, img) do  %>
            <div class="error">
            </div>
        <% end %>
    <% end %>
    <form id="photos" phx-change="validate_image">
        <%= live_file_input @uploads.images %>
    </form>
    """
  end
end
