defmodule Ciao.Images.ImageVariant do
  @moduledoc """
  A downsized copy of an `ImageRecord`
  """
  alias Ciao.Images.ImageRecord
  alias __MODULE__

  import Ecto.Changeset
  use Ciao.Schema

  schema "image_variants" do
    field(:key, :string)
    field(:dimensions, :string)
    belongs_to(:image, ImageRecord)

    timestamps()
  end

  def variant_changeset(params \\ %{}) do
    %ImageVariant{}
    |> cast(params, ~w[key dimensions image_id]a)
    |> validate_required(~w[key dimensions image_id]a)
  end
end
