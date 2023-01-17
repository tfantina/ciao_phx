defmodule Ciao.Migration do
  @moduledoc false
  alias Ecto.Migration
  require Ecto.Migration

  @doc false
  defmacro __using__(_) do
    quote do
      use Ecto.Migration
      import Ciao.Migration
    end
  end

  @doc false
  def standard_tracking_fields do
    Migration.add(:deleted_at, :utc_datetime)
    Migration.timestamps()
  end

  @doc false
  defmacro uuid_references(table, opts \\ []) do
    sanitized_opts = Keyword.merge([type: :uuid, on_delete: :restrict], opts)

    quote do
      unquote(Migration).references(unquote(table), unquote(sanitized_opts))
    end
  end

  @doc false
  defmacro uuid_primary_key(opts \\ []) do
    quote do
      opts = Keyword.merge([primary_key: true, null: false], unquote(opts))
      Migration.add(:id, :uuid, opts)
    end
  end
end
