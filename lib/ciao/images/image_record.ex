defmodule Ciao.Images.ImageRecord do
  alias Ciao.Accounts.User
  alias Ciao.Images.ImageVariant
  alias Ciao.Places.Place
  alias Ciao.Posts.Post
  alias __MODULE__

  import Ecto.Changeset
  use Ciao.Schema

  schema "images" do
    field(:key, :string)
    field(:domain, :string)
    field(:description, :string)
    field(:size, :integer)
    belongs_to(:post, Post)
    belongs_to(:place, Place)
    belongs_to(:user, User)
    has_many(:image_variants, ImageVariant, foreign_key: :image_id)

    timestamps()
  end

  def image_changeset(params \\ %{}) do
    %ImageRecord{}
    |> cast(params, ~w[key domain description size post_id place_id user_id]a)
    |> validate_required(~w[key domain size]a)
    |> validate_inclusion(:domain, ~w[post user place other])

    # |> validate_ownership_from_domain(:domain)
  end

  defp validate_ownership_from_domain(changset, field, opts \\ [])

  defp validate_ownership_from_domain(%{changes: %{domain: :post, post_id: id}}, _, _)
       when not is_nil(id),
       do: []

  defp validate_ownership_from_domain(%{changes: %{domain: :user, user_id: id}}, _, _)
       when not is_nil(id),
       do: []

  defp validate_ownership_from_domain(%{changes: %{domain: :place, place_id: id}}, _, _)
       when not is_nil(id),
       do: []

  defp validate_ownership_from_domain(%{changes: %{domain: :other}}, _, _), do: []

  defp validate_ownership_from_domain(%{changes: %{}}, _, _), do: []

  defp validate_ownership_from_domain(changeset, field, options),
    do: [{field, options[:message] || "Image must be associated with a matching domain"}]
end
