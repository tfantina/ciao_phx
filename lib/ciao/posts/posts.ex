defmodule Ciao.Posts do
  @moduledoc """
  Context for User's Posts.
  """

  alias Ciao.Images.{ImageRecord, PostImages}
  alias Ciao.Places.{Place, UserRelation}
  alias Ciao.Posts.{Comment, Post}
  alias Ciao.Repo
  alias Ecto.{Multi, UUID}

  import Ciao.EctoSupport
  import Ecto.Query

  use Ciao.Query, for: Post
  @multi Multi.new()

  def base_query do
    Post
    |> from(as: :post)
    |> preload([:user, images: [:image_variants], comments: [:user]])
  end

  def fetch_all_for_place(place) do
    Post
    |> where([p], p.place_id == ^place.id)
    |> preload([:user, images: [:image_variants], comments: [:user]])
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  def fetch_recent(user, opts \\ []) do
    Post
    |> from(as: :post)
    |> join(:left, [post: post], place in Place, on: post.place_id == place.id, as: :place)
    |> join(:left, [place: place], ur in UserRelation, on: place.id == ur.place_id, as: :ur)
    |> where([ur: ur], ur.user_id == ^user.id)
    |> scope_recent(Keyword.get(opts, :from))
    |> order_by([post: p], desc: :inserted_at)
    |> limit(20)
    |> preload([:user, images: [:image_variants], comments: [:user]])
    |> Repo.all()
  end

  defp scope_recent(query, nil), do: query
  defp scope_recent(query, from), do: where(query, [post: p], p.inserted_at < ^from)

  def create_post(%{id: id}, params) do
    params
    |> Map.put("user_id", id)
    |> Post.changeset()
    |> Repo.insert()
    |> return_post()
  end

  defp return_post({:ok, post}), do: {:ok, Repo.preload(post, [:user, :comments])}
  defp return_post({:error, _} = res), do: res
end
