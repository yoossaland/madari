defmodule Madari.Api.Notification do
  use GenServer

  @name __MODULE__
  @topic "notification"

  # Client
  def start_link(_args) do
    GenServer.start_link(@name, [], name: @name)
  end

  def is_available? do
    GenServer.call(@name, :is_available)
  end

  def state do
    GenServer.call(@name, :state)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Freedive.PubSub, @topic)
  end

  defp broadcast(frame) do
    GenServer.cast(@name, {:broadcast, frame})
  end

  defp broadcast_state(state) do
    GenServer.cast(@name, {:broadcast, {:state, state}})
  end

  # Server
  @impl true
  def init(state) do
    Process.send_after(self(), :update_state, 1)
    {:ok, state}
  end

  @impl true
  def handle_call(:is_available, _from, state) do
    {:reply, true, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:broadcast, frame}, state) do
    Phoenix.PubSub.broadcast(Freedive.PubSub, @topic, frame)
    {:noreply, state}
  end

  @impl true
  def handle_info(:update_state, state) do
    send_via_pushover("Madari Online", "Service is back online.", 1)
    {:noreply, state}
  end

  # Internal API
  defp send_via_pushover(title, message, priority) do
    if Application.get_env(:pushover, :user) != nil and Application.get_env(:pushover, :token) != nil do
      message = %Pushover.Model.Message{
        data: message,
        title: title,
        priority: priority
      }

      Pushover.Api.Messages.send(message)
    else
      IO.puts("Skip Pushover notification as credentials are missing in madari.toml")
    end
  end
end
