defmodule CiaoWeb.PlaceView do
  alias Ciao.PlacesLive.{Forms, PostComponent}
  alias Phoenix.LiveView.UploadEntry
  alias Ciao.Images.{ImageVariant, PlaceImages, PostImages}
  alias Ciao.Workers.ImageWorker

  import Ciao.PlacesLive.UploadComponent, only: [uploader: 1]
  require Logger
  use CiaoWeb, :view

  def show_images(%UploadEntry{} = image, opts \\ []), do: live_img_preview(image, opts)
  def show_images(_, _opts), do: "No images"

  def display_image(%{image_variants: variants, domain: domain} = img, size) do
    case Enum.find(variants, &(&1.dimensions == size)) do
      %ImageVariant{key: key} = variant ->
        render_img(key, domain)

      _ ->
        ImageWorker.new_resize_images(%{domain: domain, id: img.id}) |> Oban.insert()
        render_img(img.key, domain)
    end
  end

  defp render_img(key, "post") do
    case PostImages.url(key) do
      {:ok, {_, url}} ->
        img_tag(url)

      _ ->
        nil
    end
  end

  defp render_img(key, "place") do
    case PlaceImages.url(key) do
      {:ok, {_, url}} ->
        img_tag(url)

      _ ->
        nil
    end
  end

  def toggle_btn(nil), do: "New Place"
  def toggle_btn(_), do: "Close"
end
