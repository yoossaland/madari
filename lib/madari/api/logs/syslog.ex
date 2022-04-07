defmodule Madari.Api.Logs.Syslog do
  use GenServer

  @name __MODULE__
  @topic "syslog"

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
    Phoenix.PubSub.subscribe(Madari.PubSub, @topic)
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
    Phoenix.PubSub.broadcast(Madari.PubSub, @topic, frame)
    {:noreply, state}
  end

  @impl true
  def handle_info(:update_state, state) do
    {:noreply, state}
  end
end
