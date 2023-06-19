defmodule Ciao.Posts.Post do
  @moduledoc false

  alias __MODULE__
  alias Ciao.Accounts.User
  alias Ciao.Images.{ImageRecord, PostImages}
  alias Ciao.Places.Place
  alias Ciao.Posts.Comment
  import Ecto.Changeset
  use Ciao.Schema

  schema "posts" do
    field(:body, :string)
    belongs_to(:place, Place)
    belongs_to(:user, User)

    has_many(:comments, Comment, preload_order: [desc: :inserted_at])
    has_many(:images, ImageRecord)

    timestamps()
  end

  def changeset(params \\ %{}) do
    %Post{}
    |> cast(params, ~w[body user_id place_id]a)
  end

  def changeset_edit(post, params \\ %{}) do
    post
    |> cast(params, ~w[body]a)
  end
end
