defmodule Ciao.Query do
  @moduledoc """
  Basic macro for creating queries. This is something I copied from other Elixir projects 
  I've worked on, I'm not sure I love it so I haven't fully implmented all the handy 
  query methods you might expect from this API - yet.
  """
  alias __MODULE__
  alias Ciao.Context
  alias Ciao.Schema

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
