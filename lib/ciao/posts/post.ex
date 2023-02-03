defmodule Ciao.Posts.Post do
  alias __MODULE__
  alias Ciao.Accounts.User
  alias Ciao.Places.Place
  alias Ciao.Posts.Comment
  import Ecto.Changeset
  use Ciao.Schema

  schema "posts" do
    field :body, :string
    belongs_to :place, Place
    belongs_to :user, User

    has_many :comments, Comment, preload_order: [desc: :inserted_at]

    timestamps()
  end

  def changeset(params \\ %{}) do
    %Post{}
    |> cast(params, ~w[body user_id place_id]a)
  end
end
