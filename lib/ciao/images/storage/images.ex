defmodule Ciao.Storage.Images do
  @moduledoc false

  alias Ecto.{Multi, UUID}
  alias Ciao.Images.{ImageRecord, ImageVariant}
  alias Ciao.Users.User
  alias Ciao.Places.Place
  alias Ciao.Posts.Post
  alias Ciao.Repo
  alias Image

  @type ok_t :: {:ok, any()}
  @type error_t :: {:error, any()}
  @type user_or_place_t :: User.t() | Place.t() | UUID.t()

  @multi Multi.new()

  @doc false
  defmacro __using__(opts \\ []) do
    domain = Keyword.get(opts, :domain)

    quote do
      use Ciao.Storage, otp_app: :ciao
      @behaviour Ciao.Storage.Images

      @doc false
      @impl true
      def create_image(params) do
        params
        |> create_params()
        |> Map.put(:domain, unquote(domain))
        |> ImageRecord.image_changeset()
        |> Repo.insert()
      end

      defp create_params(%{user: %{id: user_id}, post: %{id: post_id}, size: size, key: key}) do
        %{key: key, size: size, user_id: user_id, post_id: post_id}
      end

      defp create_params(%{user: %{id: user_id}, size: size, key: key}) do
        %{key: key, size: size, user_id: user_id}
      end

      @doc false
      @impl true
      def create_variant(img, size) do
        generate_and_upload_variant(img, size)
      end

      defp generate_and_upload_variant(%{id: id, key: key}, size) do
        IO.inspect(download(key), label: "GETS HERE")

        with {:ok, image} <- download(key),
             IO.inspect(label: "WORD"),
             {:ok, image} <- Image.open(image),
             IO.inspect(label: "OPENE"),
             {:ok, thumb} <- Image.thumbnail(image, size, crop: :attention),
             IO.inspect(label: "THUMB?"),
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
  end

  @doc false
  @callback create_image(user_or_place_t, integer()) :: ok_t() | error_t()

  @doc false
  @callback create_variant(image :: Image.t(), opts :: String.t()) ::
              ok_t() | error_t()
end
