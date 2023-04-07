defmodule CiaoWeb.PlaceView do
  alias Ciao.PlacesLive.PostComponent
  alias Ciao.PlacesLive.Forms
  alias Phoenix.LiveView.UploadEntry
  alias Ciao.Images.PostImages

  import Ciao.PlacesLive.UploadComponent, only: [uploader: 1]

  use CiaoWeb, :view

  def show_images(%UploadEntry{} = image, opts \\ []), do: live_img_preview(image, opts)
  def show_images(_, _opts), do: "No images"

  def display_image(%{key: key}) do
    case Ciao.Images.PostImages.url(key) do
      {:ok, {_, url}} ->
        img_tag(url)

      _ ->
        nil
    end
  end
end
