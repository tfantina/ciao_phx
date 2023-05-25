defmodule Ciao.Accounts.SignIn do
  @moduledoc """
  Validation to find a user by their email 
  This should be refactored, I think using a Struct would be more elegant than 
  an `embedded_schema`.
  """
  alias __MODULE__

  import Ecto.Changeset

  use Ciao.Schema

  embedded_schema do
    field :email, :string
    field :password, :string
    field :remember_me, :boolean
  end

  def changeset(params) do
    %SignIn{}
    |> cast(params, [:email])
    |> validate_email()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end
end
