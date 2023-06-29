defmodule Ciao.Repo.Migrations.AddNotificationsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:notifications, :boolean, default: true)
    end
  end
end
