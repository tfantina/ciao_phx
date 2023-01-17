defmodule Ciao do
  @moduledoc """
  Ciao keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  defmacro ok(term), do: quote(do: {:ok, unquote(term)})
  defmacro noreply(term), do: quote(do: {:noreply, unquote(term)})
end
