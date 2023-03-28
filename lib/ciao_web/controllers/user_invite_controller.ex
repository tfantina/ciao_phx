defmodule CiaoWeb.UserInviteController do
  use CiaoWeb, :controller
  alias Ciao.Accounts
  alias CiaoWeb.UserAuth

  plug :get_user_by_invite_token

  def create(conn, _) do
    UserAuth.log_in_user(conn, conn.assigns.user)
  end

  defp get_user_by_invite_token(conn, _opts) do
    %{"token" => token} = conn.params

    if user = Accounts.get_user_by_token(token, "invite") do
      conn |> assign(:user, user) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "We were unable to find your invite, please contact support.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
