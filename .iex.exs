alias Ciao.Repo

import_if_available(Ecto.Query)

timestamp = fn ->
  {_date, {hour, minute, _second}} = :calendar.local_time()

  [hour, minute]
  |> Enum.map(&String.pad_leading(Integer.to_string(&1), 2, "0"))
  |> Enum.join(":")
end

IEx.configure(
  default_prompt: "%prefix [#{timestamp.()} :: %counter] >",
  alive_prompt: "%prefix (%node) [#{timestamp.()} :: %counter] >",
  history_size: 50,
  inspect: [
    pretty: true,
    limit: :infinity,
    width: 80
  ],
  width: 80
)

# Helper function that we'll use to generate a message when we detect that the
# module exports a given function. This is helpful for printing what exactly
# was imported or aliased on our behalf.

# Helper function that returns `use_message` if `module` appears to be loaded
# and imported or aliased. If `module` is not imported, it returns an empty
# string.
when_exported = fn module, use_message ->
  if function_exported?(module, :__info__, 1) do
    use_message
  else
    ""
  end
end

import_file_if_available("~/.iex.exs")
import_file_if_available(".iex.secret.exs")
