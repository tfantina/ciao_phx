defmodule CiaoWeb.PageLive.LogIn do
  @moduledoc false
  alias CiaoWeb.PageView

  import Ciao

  use Phoenix.LiveView

  @impl LiveView
  def mount(_, _, socket) do
    socket
    |> ok()
  end

  @impl LiveView
  def render(assigns), do: PageView.render("login.html", assigns)
end
