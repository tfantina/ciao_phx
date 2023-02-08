defmodule Ciao.Images.ProfilePics do
  @moduledoc false
  alias Ecto.{Multi, UUID}
  alias Ciao.Images
  alias Ciao.Images.{ImageRecord, ImageVariant}
  alias Ciao.Repo
  alias Image

  import Ciao.EctoSupport

  use Ciao.Storage, otp_app: :ciao

  @domain "user"
  @multi Multi.new()

  @behaviour Ciao.Storage.Images

  @impl true
  def create_image(key, user, size) do
    %{key: key, domain: @domain, size: size, user_id: user.id}
    |> ImageRecord.image_changeset()
    |> Repo.insert()
  end

  @impl true
  def create_variant(img, size \\ "120x120") do
    generate_and_upload_variant(img, size)
  end

  @impl true
  def create_variants(img, sizes \\ ["120x120"]) do
    Enum.each(sizes, &generate_and_upload_variant(img, &1))
  end

  defp generate_and_upload_variant(%{id: id, key: key}, size) do
    with {:ok, image} <- download(key),
         {:ok, image} <- Image.open(image),
         {:ok, thumb} <- Image.thumbnail(image, size, crop: :attention),
         {:ok, data} <- Image.write(thumb, :memory, suffix: ".jpg") do
      @multi
      |> put_multi_value(:key, UUID.generate())
      |> Multi.insert(:variant, fn %{key: key} ->
        %ImageVariant{key: key, dimensions: size, image_id: id}
      end)
      |> Multi.run(:upload_photo, fn _, %{variant: variant, key: key} ->
        upload(key, data)
      end)
      |> Repo.transaction()
    else
      _ ->
        {:error, "Unable to create profile variant"}
    end
  end
end
