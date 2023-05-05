defmodule CiaoWeb.PlacesLive.Edit do
  alias Ciao.{Accounts, Places}
  alias Ciao.Accounts.Authorization
  alias Ciao.Places.Place
  alias CiaoWeb.PlaceView

  alias Phoenix.LiveView

  import Ciao
  use LiveView

  @impl LiveView
  def mount(params, session, socket) do
    Authorization.authorize_user(socket, session, params, ["owner"], &load_place/3)
  end

  defp load_place(%{assigns: %{place: place}} = socket, _session, _params) do
    socket
    |> assign(:place_changeset, Place.update_changeset(place))

    # p|> assign(:users, )
  end
end
