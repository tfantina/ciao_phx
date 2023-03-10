defmodule Ciao.Places do
  alias Ciao.Accounts.User
  alias Ciao.Places.{Place, UserRelation}
  alias Ciao.Repo
  alias Ecto.Multi

  import Ciao.EctoSupport
  import Ecto.Query

  use Ciao.Query, for: Place

  @multi Multi.new()

  def fetch_all_for_user(user) do
    Place
    |> join(:left, [p], ur in UserRelation, on: p.id == ur.place_id)
    |> where([_p, ur], ur.user_id == ^user.id)
    |> Repo.all()
  end

  def fetch_users_for_place(place) do
    User
    |> join(:left, [u], ur in UserRelation, on: u.place_id)
    |> where([_u, ur], ur.place_id == ^place.id)
    |> Repo.all()
  end

  def create_place(params, user) do
    @multi
    |> put_multi_value(:user, user)
    |> Multi.insert(:place, Place.place_changeset(params))
    |> Multi.run(:user_relation, &create_user_relation/2)
    |> Repo.transaction()
  end

  defp create_user_relation(repo, %{place: place, user: user}) do
    %{user_id: user.id, place_id: place.id, role: "owner"}
    |> UserRelation.changeset_create()
    |> repo.insert()
  end
end
