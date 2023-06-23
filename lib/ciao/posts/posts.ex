defmodule Ciao.Posts do
  @moduledoc """
  Context for User's Posts.
  """
  alias Ciao.Accounts.User
  alias Ciao.Images.{ImageRecord, PostImages}
  alias Ciao.Places.{Place, UserRelation}
  alias Ciao.Posts.{Comment, Post}
  alias Ciao.Repo
  alias Ecto.UUID

  import Ciao.EctoSupport
  import Ecto.Query

  use Ciao.Query, for: Post

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

  @spec fetch_recent(User.t() | UUID.t()) :: [Post.t()]
  def fetch_recent(user, opts \\ [])
  def fetch_recent(%User{} = user, opts), do: fetch_recent(user.id, opts)

  def fetch_recent(user_id, opts) do
    Post
    |> from(as: :post)
    |> join(:left, [post: post], place in Place, on: post.place_id == place.id, as: :place)
    |> join(:left, [place: place], ur in UserRelation, on: place.id == ur.place_id, as: :ur)
    |> where([ur: ur], ur.user_id == ^user_id)
    |> scope_recent(Keyword.get(opts, :from))
    |> scope_after(Keyword.get(opts, :since))
    |> order_by([post: p], desc: :inserted_at)
    |> limit(^Keyword.get(opts, :limit, 20))
    |> preload(^Keyword.get(opts, :preload, []))
    |> Repo.all()
  end

  defp scope_recent(query, nil), do: query
  defp scope_recent(query, from), do: where(query, [post: p], p.inserted_at < ^from)
  defp scope_after(query, nil), do: query
  defp scope_after(query, since), do: where(query, [post: p], p.inserted_at > ^since)

  def create_post(%{id: id}, params) do
    params
    |> Map.put("user_id", id)
    |> Post.changeset()
    |> Repo.insert()
    |> return_post()
  end

  def update_post(post, params) do
    post
    |> Post.changeset_edit(params)
    |> Repo.update()
    |> return_post()
  end

  defp return_post({:ok, post}), do: {:ok, Repo.preload(post, [:user, :comments])}
  defp return_post({:error, _} = res), do: res
end
