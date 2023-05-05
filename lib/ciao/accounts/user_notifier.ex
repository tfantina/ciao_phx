defmodule Ciao.Accounts.UserNotifier do
  @moduledoc false
  import Swoosh.Email

  alias Ciao.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Ciao", "no-reply@ciaoplace.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver email to sign in user
  """
  def deliver_magic_code(user, url) do
    deliver(user.email, "Ciao, come on in!", """
    ==============================

    Hi #{user.email},

    You are receiving this because you or someone with your email address just
    attempted to sign into Ciao. Please follow the link below to be automatically
    signed in within the next 10 minutes.

    #{url}

    If you did not just try to sign in please be sure your email is secure and
    this email.

    ==============================
    """)
  end

  @doc """
  Deliver user invite
  """
  def deliver_user_invite(invite, url) do
    deliver(invite.user.email, "You've been invited...", """
    ==============================

    Hi #{invite.user.email},

    #{invite.invitor.email} has invited you to a place: #{invite.place.name}.
    You can follow along by clicking the link below.


    #{url}

    Ciao is a small anti-social-social-network for keeping up with what
    matters most in life.  If you already have an account #{invite.place.name}
    will be added to your places. Otherwise you will be given access to this place,
    there is no need to sign up, a secure link will be emailed to you when you
    want to access what #{invite.invitor.email} sent you.

    ==============================
    """)
  end
end
