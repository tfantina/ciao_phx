defmodule Ciao.Places.UserRelation do
  @moduledoc false
  alias Ciao.Accounts.User
  alias Ciao.Places.Place
  alias __MODULE__

  import Ecto.Changeset
  use Ciao.Schema

  schema "user_relations" do
    field :role, :string
    field :pending, :boolean, default: true
    belongs_to :user, User
    belongs_to :place, Place

    timestamps()
  end

  def changeset_create(params \\ %{}) do
    %UserRelation{}
    |> cast(params, ~w[role user_id place_id]a)
    |> validate_inclusion(:role, ~w[owner contributor viewer])
    |> validate_required(~w[role user_id place_id]a)
    |> unique_constraint([:user_id, :place_id])
  end

  def changeset_update(role, params) do
    role
    |> cast(params, [:role])
    |> validate_inclusion(:role, ~w[owner contributor viewer])
  end
end
