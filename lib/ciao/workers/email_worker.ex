defmodule Ciao.Workers.EmailWorker do
  @moduledoc """
  Common functions for sending emails via Oban
  """
  alias Ciao.Accounts
  alias Ciao.Accounts.{Invites, UserNotifier, UserToken}
  alias Ciao.Repo
  alias Ciao.URL
  alias Oban.{Job, Worker}
  alias Ecto.Multi

  import Ciao

  import Ciao.EctoSupport

  use Worker, queue: :mailer, max_attempts: 7

  @multi Multi.new()

  @impl Oban.Worker
  def perform(%Job{args: %{"task" => "sign_in_user", "user_id" => id}}), do: send_sign_in(id)

  def perform(%Job{args: %{"task" => "invite_user", "invite_id" => id}}),
    do: send_invite_welcome(id)

  def perform(%Job{args: %{"task" => "add_user", "invite_id" => id}}), do: send_place_welcome(id)

  #
  # Job creators
  #
  def new_sign_in_from_email(user, params),
    do: new(%{"task" => "sign_in_user", "user_id" => user.id})

  def new_email_invite(invite, nil), do: new(%{"task" => "invite_user", "invite_id" => invite.id})

  def new_email_invite(invite, _), do: new(%{"task" => "add_user", "invite_id" => invite.id})

  #
  # Job handlers
  #
  @spec send_sign_in(UUID.t()) :: :ok
  def send_sign_in(id) do
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
      UserNotifier.deliver_magic_code(user, URL.build_magic_url(encoded_token))
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
end
