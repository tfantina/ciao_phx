defmodule Ciao.Repo.Migrations.ImageVariants do
  use Ciao.Migration

  def change do
    create table(:image_variants, primary_key: false) do
      uuid_primary_key()
      add(:key, :string, null: false)
      add(:dimensions, :string, null: false)
      add(:image_id, uuid_references(:images))

      standard_tracking_fields()
    end
  end
end
