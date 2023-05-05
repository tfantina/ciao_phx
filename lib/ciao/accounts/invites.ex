defmodule Ciao.Accounts.Invites do
  @moduledoc """
  Context for user invites
  """
  alias Ciao.Accounts.Invite
  import Ecto.Query

  use Ciao.Query, for: Invite

  def base_query do
    Invite
    |> from(as: :invite)
    |> preload([:user, :invitor, :place])
  end
end
