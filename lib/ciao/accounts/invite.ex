defmodule Ciao.Accounts.Invite do
  @moduledoc false
  alias Ciao.Accounts.User
  alias Ciao.Places.{Place, UserRelation}
  alias __MODULE__

  import Ecto.Changeset
  use Ciao.Schema

  schema "invites" do
    belongs_to(:user, User)
    belongs_to(:place, Place)
    belongs_to(:invitor, User)

    timestamps()
  end

  def changeset_create(params \\ %{}) do
    %Invite{}
    |> cast(params, ~w[user_id place_id invitor_id]a)
    |> unique_constraint([:user_id, :place_id])
  end
end
