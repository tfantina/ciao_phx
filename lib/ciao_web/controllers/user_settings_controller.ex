defmodule CiaoWeb.UserSettingsController do
  use CiaoWeb, :controller

  alias Ciao.Accounts
  alias CiaoWeb.UserAuth

  plug(:assign_email_and_password_changesets)

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_notifications", "user" => params}) do
    user = conn.assigns.current_user

    case Accounts.apply_user_notifications(user, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:success, "Your notification preferences have been updated")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was a problem updating your preferences")
        |> render("edit.html", notification_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_login"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_signin(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "You will now log in via a secure link in your email!")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_login_password"} = params) do
    user = conn.assigns.current_user

    if params["user"]["login_preference"] == "true" do
      case Accounts.initiate_passworded_signin(
             user,
             &Routes.user_reset_password_url(conn, :new_login, &1)
           ) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "You will be sent an email confirmation.")
          |> redirect(to: Routes.user_settings_path(conn, :edit))

        {:error, changeset} ->
          render(conn, "edit.html", password_changeset: changeset)
      end
    else
      conn
      |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:user, user)
    |> assign(:notification_changeset, Accounts.change_user_notifications(user))
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
    |> assign(:login_changeset, Accounts.change_user_login(user))
  end
end
