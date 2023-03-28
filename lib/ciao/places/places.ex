defmodule Ciao.Places do
  alias Ciao.Accounts
  alias Ciao.Accounts.{Invite, User}
  alias Ciao.Places.{Place, UserRelation}
  alias Ciao.Repo
  alias Ciao.Workers.EmailWorker
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

  def add_user(invitor_id, place_id, invitee_email, role) do
    params = %{place_id: place_id, role: role}

    @multi
    |> Multi.run(:user, fn _repo, _ ->
      Accounts.find_or_create_by_email(invitee_email)
    end)
    |> Multi.run(:params, fn _, %{user: user} ->
      {:ok, %{place_id: place_id, role: role, user_id: user.id}}
    end)
    |> Multi.insert(:relation, fn %{params: params} ->
      UserRelation.changeset_create(params)
    end)
    |> Multi.run(:invite, fn repo, %{params: params} ->
      params
      |> Map.put(:invitor_id, invitor_id)
      |> Invite.changeset_create()
      |> repo.insert()
    end)
    |> Multi.run(:email_invite, fn repo, %{invite: invite, user: user} ->
      invite
      |> EmailWorker.new_email_invite(user.confirmed_at)
      |> Oban.insert()
    end)
    |> Repo.transaction()
  end
end
