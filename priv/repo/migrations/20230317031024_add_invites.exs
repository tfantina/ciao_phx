defmodule Ciao.Repo.Migrations.AddInvite do
  use Ciao.Migration

  def change do
    create table(:invites, primary_key: false) do
      uuid_primary_key()
      add(:user_id, uuid_references(:users))
      add(:place_id, uuid_references(:places))
      add(:invitor_id, uuid_references(:users))
      add(:relation_id, uuid_references(:user_relations))
      standard_tracking_fields()
    end

    alter table(:users) do
      add(:login_preference, :string)
      modify(:hashed_password, :string, null: true)
    end

    unique_index(:invites, [:user_id, :place_id])
  end
end
