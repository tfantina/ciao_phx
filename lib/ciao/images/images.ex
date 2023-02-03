defmodule Ciao.Images do
  alias Ecto.Multi
  alias Ciao.Images.Image
  alias Ciao.Repo
  @multi Multi.new()

  def create_image(key, user, size, domain) do
    %{domain: Atom.to_string(domain), key: key, user_id: user.id, size: size}
    |> Image.image_changeset()
    |> Repo.insert()
  end
end
