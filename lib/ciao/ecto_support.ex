defmodule Ciao.EctoSupport do
  @moduledoc false
  alias Ecto.Multi
  import Ciao

  def put_multi_value(multi, key, value), do: Multi.run(multi, key, fn _, _ -> ok(value) end)
end
