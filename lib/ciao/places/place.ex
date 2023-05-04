defmodule Ciao.Places.Place do
  alias __MODULE__
  alias Ciao.Places.UserRelation
    alias Ciao.Images.ImageRecord
  import Ecto.Changeset
  use Ciao.Schema

  schema "places" do
    field :name, :string
    field :description, :string
    field :public, :boolean, default: false
    field :slug, :string

    has_many :user_relations, UserRelation
    has_many :place_pics, ImageRecord


    timestamps()
  end

  def place_changeset(params \\ %{}) do
    %Place{}
    |> cast(params, ~w[name description public slug]a)
    |> validate_required(~w[name]a)
    |> unique_constraint(:slug)
  end

  def update_changeset(place, params \\ %{}) do
    place
    |> cast(params, ~w[name description public slug]a)
    |> validate_required(~w[name]a)
    |> unique_constraint(:slug)
  end
end
