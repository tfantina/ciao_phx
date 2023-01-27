defmodule Ciao.Posts do
  alias Ciao.Posts.{Post, Comment}
  alias Ciao.Repo

  import Ciao.EctoSupport
  import Ecto.Query

  def fetch_all_for_place(place) do
    Post
    |> where([p], p.place_id == ^place.id)
    |> preload([:comments, :user])
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

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
