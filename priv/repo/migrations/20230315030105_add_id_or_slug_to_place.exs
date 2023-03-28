defmodule Ciao.Repo.Migrations.AddIdOrSlugToPlace do
  use Ecto.Migration

  def change do
    alter table(:places) do
      add :id_or_slug, :string
    end

    :places
    |> unique_index(:id_or_slug, where: "deleted_at is NULL")
    |> create()
  end
end
