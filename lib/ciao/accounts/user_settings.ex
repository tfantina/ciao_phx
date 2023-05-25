defmodule Ciao.Accounts.UserSettings do
  @moduledoc false
  alias __MODULE__
  alias Ciao.Accounts.User

  import Ecto.Changeset

  use Ciao.Schema

  embedded_schema do
    field :password, :string
    field :current_password, :string
    field :login_preference, :string
  end

  def changeset(params, opts \\ []) do
    %UserSettings{}
    |> cast(params, [:password, :current_password, :login_preference])
    |> validate_confirmation(:password, message: "does not match password")
    |> User.validate_password(opts)
  end
end
