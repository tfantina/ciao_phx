defmodule Ciao.Repo.Migrations.PostAdjustments do
  use Ecto.Migration

  def up do
    alter table(:posts) do
      add(:title, :string)
      modify(:body, :text, null: true)
    end
  end

  def down do
    alter table(:posts) do
      remove(:title)
      modify(:body, :text, null: false)
    end
  end
end
