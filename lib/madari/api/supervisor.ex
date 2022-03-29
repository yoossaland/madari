defmodule Madari.Api.Supervisor do
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Madari.Api.Notification, [[name: Madari.Api.Notification]]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
