defmodule Ciao.Repo.Migrations.AddStatusToUserRelation do
  use Ecto.Migration

  def change do
    alter table(:user_relations) do
      add(:pending, :boolean, default: true)
    end
  end
end
