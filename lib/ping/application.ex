defmodule Ping.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PingWeb.Telemetry,
      Ping.Repo,
      {DNSCluster, query: Application.get_env(:ping, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ping.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ping.Finch},
      # Start a worker by calling: Ping.Worker.start_link(arg)
      # {Ping.Worker, arg},
      # Start to serve requests, typically the last entry
      PingWeb.Endpoint,
      PingWeb.WebSocketUserTracker
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ping.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
