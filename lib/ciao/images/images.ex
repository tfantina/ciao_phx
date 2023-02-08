defmodule Ciao.Images do
  @moduledoc """
  Module for creating and managing images.
  Images are used throughout the site and in varying contexts however they all
  live under the Images umbrella.  If this ever becomes unmanagable these functions
  should be extracted into behaviours and composed in seperate modules.
  """
  alias __MODULE__
  alias Ciao.Accounts.User
  alias Ecto.{Multi, UUID}
  alias Ciao.Images.{ImageRecord, ImageVariant, ProfilePics}
  alias Ciao.Repo
  alias Image, as: Img

  @multi Multi.new()

  use Ciao.Query, for: ImageRecord

  @spec create_image(User.t(), integer(), atom()) :: {:ok, Image.t()} | {:error, any()}
  def create_image(user, size, domain) do
    %{domain: Atom.to_string(domain), user_id: user.id, size: size}
    |> ImageRecord.image_changeset()
    |> Repo.insert()
  end

  @doc """
  Functions for generating image variants/optomizations in specific sizes friendly for profile pics,
  mobile, etc.
  """
  @spec create_variant(UUID.t(), atom(), Keyword.t()) :: {:ok, Image.t()} | {:error, any()}
  def create_variant(id, :profile_pic, opts \\ []) do
    with image <- Images.get(id),
         {:ok, {_, url}} <- ProfilePics.url(image.id) do
      variant = Keyword.get(opts, :sizes, ["120x120"])
      generate_and_upload_variant(image, url, variant)
    else
      _ ->
        {:error, "unable to create variants"}
    end
  end

  defp generate_and_upload_variant(image, url, size) do
    with {:ok, thumb} <- Img.thumbnail(url, size, crop: :attention),
         {:ok, data} <- Image.write(thumb, :memory, suffix: ".jpg") do
      @multi
      |> Multi.insert(:variant, fn _, _ -> %ImageVariant{dimensions: size, image_id: image.id} end)
      |> Multi.run(:upload_photo, fn _, %{variant: variant} ->
        ProfilePics.upload(variant.id, data)
      end)
      |> Multi.transaction()
    end
  end
end
