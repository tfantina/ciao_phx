defmodule Ciao.Posts.Comment do
  alias __MODULE__
  alias Ciao.Accounts.User
  alias Ciao.Posts.Post
  import Ecto.Changeset
  use Ciao.Schema

  schema "comments" do
    field :body, :string
    belongs_to :user, User
    belongs_to :post, Post

    timestamps()
  end

  def comment_changeset(params \\ %{}) do
    %Comment{}
    |> cast(params, ~w[body user_id post_id]a)
  end
end
