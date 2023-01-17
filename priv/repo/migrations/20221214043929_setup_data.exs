defmodule Ciao.Repo.Migrations.SetupData do
  use Ciao.Migration

  def up do
    create table(:places, primary_key: false) do
      uuid_primary_key()
      add :name, :string, null: false
      add :description, :string
      add :public, :boolean, default: false, null: false
      add :slug, :string

      standard_tracking_fields()
    end

    :places
    |> unique_index(:slug, where: "deleted_at is NULL")
    |> create()

    create table(:posts, primary_key: false) do
      uuid_primary_key()
      add :body, :string, null: false
      add :place_id, uuid_references(:places)
      add :user_id, uuid_references(:users)

      standard_tracking_fields()
    end

    create table(:comments, primary_key: false) do
      uuid_primary_key()
      add :body, :string, null: false
      add :user_id, uuid_references(:users)
      add :post_id, uuid_references(:posts)

      standard_tracking_fields()
    end

    create table(:user_relations, primary_key: false) do
      uuid_primary_key()
      add :role, :string, null: false, default: "reader"
      add :user_id, uuid_references(:users)
      add :place_id, uuid_references(:places)

      standard_tracking_fields()
    end

    :user_relations
    |> unique_index([:user_id, :place_id],
      name: "user_place_relation",
      where: "deleted_at is NULL"
    )
    |> create()
  end

  def down do
    :user_relations
    |> unique_index([:user_id, :place_id],
      name: "user_place_relation",
      where: "deleted_at is NULL"
    )
    |> drop_if_exists

    :places
    |> unique_index(:slug, where: "deleted_at is NULL")
    |> drop_if_exists()

    drop table(:user_relations)
    drop table(:comments)
    drop table(:posts)
    drop table(:places)
  end
end
