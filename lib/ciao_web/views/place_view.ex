defmodule CiaoWeb.PlaceView do
  alias Ciao.PlacesLive.PostComponent
  alias Ciao.PlacesLive.Forms
  alias Phoenix.LiveView.UploadEntry
  alias Ciao.Images.PostImages
  alias Ciao.Images.ImageVariant
  alias Ciao.Workers.ImageWorker

  import Ciao.PlacesLive.UploadComponent, only: [uploader: 1]

  use CiaoWeb, :view

  def show_images(%UploadEntry{} = image, opts \\ []), do: live_img_preview(image, opts)
  def show_images(_, _opts), do: "No images"

  def display_image(%{image_variants: [_ | _] = variants, domain: domain} = img, size) do
    case Enum.find(variants, &(&1.dimensions == size)) do
      %ImageVariant{key: key} -> 
      render_img(key, domain)
      _ -> 
      ImageWorker.new_resize_images(%{domain: domain, id: img.id}) |> Oban.insert()
      render_img(img.key, domain)
    end
  end

  def display_image(%{domain: domain} = img, _), do: render_img(img.key, domain)

  defp render_img(key, "post") do
    case Ciao.Images.PostImages.url(key) do
      {:ok, {_, url}} ->
        img_tag(url)

      _ ->
        nil
    end
  end

    defp render_img(key, "place") do
    case Ciao.Images.PlaceImages.url(key) do
      {:ok, {_, url}} ->
        img_tag(url)

      _ ->
        nil
    end
  end
end
