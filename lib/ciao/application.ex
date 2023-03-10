defmodule Ciao.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Ciao.Repo,
      # Start the Telemetry supervisor
      CiaoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ciao.PubSub},
      # Start the Endpoint (http/https)
      CiaoWeb.Endpoint,
      # Start a worker by calling: Ciao.Worker.start_link(arg)
      # {Ciao.Worker, arg}
      {Oban, Application.fetch_env!(:ciao, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ciao.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CiaoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
