defmodule Ciao.Repo.Migrations.AddImagesTable do
  use Ciao.Migration

  def change do
    create table(:images, primary_key: false) do
      uuid_primary_key()
      add(:domain, :string, null: false)
      add(:key, :string, null: false)
      add(:description, :string)
      add(:place_id, uuid_references(:places))
      add(:user_id, uuid_references(:users))
      add(:post_id, uuid_references(:posts))
      add(:size, :integer, null: false)

      standard_tracking_fields()
    end

    alter table(:users) do
      add(:profile_pic, uuid_references(:images))
    end

    alter table(:places) do
      add(:place_pic, uuid_references(:images))
    end
  end
end
