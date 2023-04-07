defmodule CiaoWeb.PageLive.Index do
  @moduledoc false
  alias Ciao.Accounts
  alias Ciao.Accounts.{User, SignIn}
  alias CiaoWeb.PageView
  alias CiaoWeb.UserAuth
  alias Ciao.Workers.EmailWorker
  alias Ecto.Changeset

  import Ciao

  use Phoenix.LiveView

  @impl LiveView
  def mount(_, _, socket) do
    socket
    |> ok()
  end

  @impl LiveView
  def render(assigns), do: PageView.render("index.html", assigns)
end
