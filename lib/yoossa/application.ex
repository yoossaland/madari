defmodule Yoossa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Yoossa.Repo,
      # Start the Telemetry supervisor
      YoossaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Yoossa.PubSub},
      # Start the Endpoint (http/https)
      YoossaWeb.Endpoint
      # Start a worker by calling: Yoossa.Worker.start_link(arg)
      # {Yoossa.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Yoossa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    YoossaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
