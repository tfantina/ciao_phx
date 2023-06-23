defmodule Ciao.Notifications.DataAggregation do
  @moduledoc """
  Compiles data required for sending some user emails (weekly digests, etc.)
  """
  alias Ciao.Places.{Place, UserRelation}
  alias Ciao.Posts.Post

  import Ecto.Query

  # def generate_digeset(user_id) do
  #   Post 
  #   |> from(as: :post)
  #   |> join(:left, [post: post], place in Place, on post.place_id == place.id, as: :place)
  #   |> join(:left, [place: place], ur in UserRelation, on: place.id == ur.place_id, as: :ur)
  #   |> where([ur: ur], ur.user_id == ^user_id)
  #   |> scope
  #   from(ur in UserRelation, where: ur.user_id == ^user_id)
  # end
end
