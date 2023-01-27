defmodule Ciao.Context do
  require Ciao.Query

  def get(context, id, opts) do
    opts
    |> context.base_query()
    |> context.repo().get(id)
  end
end
