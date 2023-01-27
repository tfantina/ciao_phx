defmodule Ciao.Query do
  alias __MODULE__
  alias Ciao.Schema
  alias Ciao.Context

  require Ecto.Query

  defmacro __using__(opts) do
    schema = Keyword.fetch!(opts, :for)
    repo = Keyword.get(opts, :repo, Ciao.Repo)

    quote bind_quoted: [schema: schema, repo: repo] do
      @behaviour Query
      @schema schema
      @repo repo

      @doc false
      def schema, do: @schema

      @doc false
      def repo, do: @repo

      def get(id, opts \\ []), do: Context.get(__MODULE__, id, opts)

      def base_query(_opts), do: schema()

      defoverridable get: 1, get: 2, repo: 0, schema: 0
    end
  end

  @callback get(attrs :: Keyword.t() | map, opts :: Keyword.t()) :: Schema.t()
end
