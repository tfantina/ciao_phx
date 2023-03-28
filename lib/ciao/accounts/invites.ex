defmodule Ciao.Accounts.Invites do
  alias Ciao.Accounts.Invite
  import Ecto.Query

  use Ciao.Query, for: Invite

  def base_query do
    Invite
    |> from(as: :invite)
    |> preload([:user, :invitor, :place])
  end
end
