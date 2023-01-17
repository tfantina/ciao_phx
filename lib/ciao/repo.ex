defmodule Ciao.Repo do
  use Ecto.Repo,
    otp_app: :ciao,
    adapter: Ecto.Adapters.Postgres
end
