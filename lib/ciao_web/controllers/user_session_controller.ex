defmodule CiaoWeb.UserSessionController do
  use CiaoWeb, :controller

  alias Ciao.Accounts
  alias CiaoWeb.UserAuth
  alias Ciao.Workers.EmailWorker

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

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    IO.inspect(label: "OPKL")

    if user = Accounts.get_user_by_email(email) do
      user
      |> EmailWorker.new_sign_in_from_email(nil)
      |> Oban.insert()

      redirect(conn, to: "/users/sign_in/confirm")
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      IO.inspect(label: "WORD")
      redirect(conn, to: "/users/sign_in/confirm")
    end
  end

  def sign_in(conn, %{"token" => token}) do
    if user = Accounts.get_user_by_token(token, "sign_in") do
      UserAuth.log_in_user(conn, user)
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
