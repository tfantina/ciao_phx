defmodule CiaoWeb.AccountLive.Index do
  alias Ciao.Accounts
  alias Ciao.Images.ImageRecord
  alias CiaoWeb.AccountView
  alias Phoenix.LiveView

  import Ciao

  use LiveView

  @impl LiveView
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    socket
    |> assign(:user, user)
    |> assign(:photo, nil)
    |> assign(:image_changeset, ImageRecord.image_changeset())
    |> allow_upload(:profile_pic,
      accept: ~w[.jpg .jpeg .png .gif],
      max_entries: 1,
      max_file_size: 10_000_000
    )
    |> ok()
  end

  @impl LiveView
  def render(assigns), do: AccountView.render("index.html", assigns)

  @impl LiveView
  def handle_event("update_image", _params, socket) do
    %{uploads: uploads} = socket.assigns

    socket
    |> assign(:photo, get_image(uploads.profile_pic, uploads.profile_pic.ref))
    |> noreply()
  end

  def handle_event("save_image", _params, %{assigns: %{user: user, uploads: uploads}} = socket) do
    data = read_file(socket, uploads)

    case Accounts.upload_profile_pic(user, data) do
      {:ok, _} ->
        socket
        |> noreply()

      _ ->
        socket
        |> noreply()
    end
  end

  defp get_image(%{entries: entries}, ref) do
    Enum.find(entries, &(&1.upload_ref == ref))
  end

  defp read_file(_socket, %{profile_pic: %{entries: []}}), do: nil

  defp read_file(socket, _entries) do
    socket
    |> consume_uploaded_entries(:profile_pic, fn %{path: path}, _entry ->
      {:ok, %{size: size}} = File.stat(path)
      %{data: File.read!(path), size: size} |> ok()
    end)
    |> Enum.at(0)
  end
end
