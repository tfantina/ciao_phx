defmodule CiaoWeb.UserSessionController do
  use CiaoWeb, :controller

  alias Ciao.{Accounts, URL}
  alias Ciao.Workers.EmailWorker
  alias CiaoWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password} = user_params}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "/", error_message: "Invalid email or password")
    end
  end

  def create(conn, %{"user" => %{"email" => email, "remember_me" => remember} = user_params}) do
    if user = Accounts.get_user_by_email(email) do
      user
      |> EmailWorker.new_sign_in_from_email(remember)
      |> Oban.insert()

      redirect(conn, to: "/users/sign_in/confirm")
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      redirect(conn, to: "/users/sign_in/confirm")
    end
  end

  def sign_in(conn, %{"token" => token}) do
    {token, remember} = URL.get_remember_token(token)
    if user = Accounts.get_user_by_token(token, "sign_in") do
      UserAuth.log_in_user(conn, user, %{"remember_me" => remember})
    else
      conn
      |> redirect(to: "/")
      |> halt()
    end
  end

  def magic(conn, _) do
    render(conn, "magic.html")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
