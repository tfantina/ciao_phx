defmodule Ciao.Accounts.Authorization do
  @moduledoc false
  alias Ciao.{Accounts, Places}
  alias CiaoWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView

  import Ciao

  @doc """
  Authorizes a user by seeing their role in a particular place. 
  """
  def authorize_user(socket, session, params, roles, callback) do
    place = Places.get(params["id_or_slug"]) |> Ciao.Repo.preload(place_pics: [:image_variants])
    user = Accounts.get_user_by_session_token(session["user_token"])
    user_places = Enum.map(user.user_relations, & &1.place_id)

    with true <- place.id in user_places,
         user_relation <- Enum.find(user.user_relations, &(&1.place_id == place.id)),
         true <- user_relation.role in roles do
      socket
      |> LiveView.assign(:user, user)
      |> LiveView.assign(:place, place)
      |> LiveView.assign(:user_relation, user_relation)
      |> callback.(session, params)
    else
      _ ->
        socket
        |> LiveView.redirect(to: Routes.live_path(socket, CiaoWeb.PlaceLive.Index))
        |> ok()
    end
  end
end
