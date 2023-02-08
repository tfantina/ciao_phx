defmodule Ciao.Storage.Images do
  @moduledoc false

  alias Ecto.UUID
  alias Ciao.Images.ImageRecord
  alias Ciao.Users.User
  alias Ciao.Places.Place

  @type ok_t :: {:ok, any()}
  @type error_t :: {:error, any()}
  @type user_or_place_t :: User.t() | Place.t() | UUID.t()

  @doc false
  @callback create_image(user_or_place_t, integer()) :: ok_t() | error_t()

  @doc false
  @callback create_variant(image :: Image.t(), opts :: String.t()) ::
              ok_t() | error_t()

  @doc false
  @callback create_variants(image :: Image.t(), opts :: Keyword.t()) :: ok_t() | error_t()
end
