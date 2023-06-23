defmodule Ciao.Workers.EmailWorker do
  @moduledoc """
  Common functions for sending emails via Oban
  """
  alias Ciao.{Accounts, Mailer, Posts, Repo, URL}
  alias Ciao.Accounts.{Invites, UserNotifier, UserToken}
  alias Ecto.Multi
  alias Oban.{Job, Worker}

  import Ciao

  import Ciao.EctoSupport

  use Worker, queue: :mailer, max_attempts: 7

  @multi Multi.new()

  @impl Oban.Worker
  def perform(%Job{args: %{"task" => "sign_in_user", "user_id" => id, "remember_me" => remember}}),
    do: send_sign_in(id, remember)

  def perform(%Job{args: %{"task" => "invite_user", "invite_id" => id}}),
    do: send_invite_welcome(id)

  def perform(%Job{args: %{"task" => "add_user", "invite_id" => id}}), do: send_place_welcome(id)

  def perform(%Job{args: %{"task" => "weekly_digest"}}), do: queue_weekly_digests()

  def perform(%Job{args: %{"task" => "generate_digest", "id" => id}}),
    do: create_and_send_digest(id)

  #
  # Job creators
  #
  def new_sign_in_from_email(user, params),
    do: new(%{"task" => "sign_in_user", "user_id" => user.id, "remember_me" => params})

  def new_email_invite(invite, nil), do: new(%{"task" => "invite_user", "invite_id" => invite.id})

  def new_email_invite(invite, _), do: new(%{"task" => "add_user", "invite_id" => invite.id})

  def new_digest_email(user), do: new(%{"task" => "generate_digest", "id" => user.id})

  #
  # Job handlers
  #
  @spec send_sign_in(UUID.t(), String.t()) :: :ok
  def send_sign_in(id, remember) do
    @multi
    |> put_multi_value(:user, Accounts.get_user!(id))
    |> Multi.run(:token, fn _, %{user: user} ->
      user
      |> UserToken.build_email_token("sign_in")
      |> ok()
    end)
    |> Multi.insert(:user_token, fn %{token: {_, user_token}} ->
      user_token
    end)
    |> Multi.run(:send_notification, fn _, %{user: user, token: {encoded_token, _}} ->
      UserNotifier.deliver_magic_code(user, URL.build_magic_url(encoded_token, remember))
    end)
    |> Repo.transaction()
  end

  @spec send_invite_welcome(UUID.t()) :: :ok
  def send_invite_welcome(id) do
    @multi
    |> put_multi_value(:invite, id |> Invites.get() |> Repo.preload([:user, :place, :invitor]))
    |> Multi.run(:token, fn _, %{invite: invite} ->
      {encoded_token, user_token} = UserToken.build_email_token(invite.user, "invite")
      {:ok, %{encoded: encoded_token, user: user_token}}
    end)
    |> Multi.insert(:user_token, fn %{token: %{user: user_token}} ->
      user_token
    end)
    |> Multi.run(:send_notification, fn _, %{invite: invite, token: %{encoded: encoded_token}} ->
      UserNotifier.deliver_user_invite(invite, URL.build_invite_url(encoded_token))
    end)
    |> Repo.transaction()
  end

  @spec send_place_welcome(UUID.t()) :: :ok
  def send_place_welcome(id) do
    @multi
    |> put_multi_value(:invite, id |> Invites.get() |> Repo.preload([:user, :place, :invitor]))
    |> Multi.run(:token, fn _, %{invite: invite} ->
      {encoded_token, user_token} = UserToken.build_email_token(invite.user, "invite")
      {:ok, %{encoded: encoded_token, user: user_token}}
    end)
    |> Multi.insert(:user_token, fn %{token: %{user: user_token}} ->
      user_token
    end)
    |> Multi.run(:send_notification, fn _, %{invite: invite, token: %{encoded: encoded_token}} ->
      UserNotifier.deliver_user_invite(invite, URL.build_invite_url(encoded_token))
    end)
    |> Repo.transaction()
  end

  @spec queue_weekly_digests :: [{:ok, Job.t()}]
  def queue_weekly_digests do
    users = Accounts.all()
    Enum.each(users, &(&1 |> new_digest_email() |> Repo.insert()))
  end

  @spec create_and_send_digest(UUID.t()) :: :ok
  def create_and_send_digest(user_id) do
    since = Timex.shift(Timex.now(), days: -7)
    user = Accounts.get_user!(user_id)
    posts = Posts.fetch_recent(user_id, since: since, limit: 10, preload: [:user, :place])

    user
    |> UserNotifier.weekly_digest(posts)
    |> Ciao.Mailer.deliver()
  end
end
