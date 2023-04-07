defmodule Ciao.Account.SignInComponent do
  @moduledoc false
  alias Ciao.Accounts
  alias Ciao.Accounts.{User, SignIn}

  import Phoenix.HTML.Form
  import Ciao

  use Phoenix.LiveComponent

  def update(assigns, socket) do
    socket
    |> assign(:show_password, false)
    |> assign(:changeset, SignIn.changeset(%{}))
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for let={f}
              for={@changeset}
              id="signin"
              phx-change={:validate_email}
              phx-trigger-action={false}
              phx-target={@myself}
              action={"/users/log_in/"}
              as="user">
          <%= label f, "enter your email" %>
          <%= email_input f, :email %>
          <%= if @show_password do %>
              <%= label f, "password" %>
              <%= password_input f, :password %>
          <% end %>
          <%= submit "Sign in" %>
      </.form>
    </div>
    """
  end

  @impl LiveView

  def handle_event(
        "validate_email",
        %{"user" => %{"email" => email}},
        %{assigns: %{show_password: false}} = socket
      ) do
    if SignIn.changeset(%{email: email}).valid? do
      case get_user_by_type(email) do
        %User{email: email} ->
          socket
          |> assign(:show_password, true)
          |> noreply()

        _ ->
          socket
          |> noreply()
      end
    else
      socket
      |> noreply()
    end
  end

  def handle_event("validate_email", _, socket), do: {:noreply, socket}

  defp get_user_by_type(email) do
    case Accounts.get_user_by_email(email) do
      %User{login_preference: "password"} = user -> user
      res -> nil
    end
  end
end
