defmodule Ciao.Accounts.SignIn do
  alias __MODULE__

  import Ecto.Changeset

  use Ciao.Schema

  embedded_schema do
    field :email
    field :password
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
