defmodule Madari.Api.Sysinfo do
  use GenServer

  @name __MODULE__
  @topic "sysinfo"

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
    GenServer.cast(@name, {:broadcast, {:sysinfo, state}})
  end

  # Server
  @impl true
  def init(state) do
    Process.send_after(self(), :update_state, 1)
    {:ok, state}
  end

  @impl true
  def handle_info(:update_state, _state) do
    Process.send_after(self(), :update_state, 1000)
    uptime_stdout = query_uptime()
    state = %{
      hostname: query_hostname(),
      datetime: query_datetime(),
      uptime: uptime_stdout,
      uptime_time: parse_uptime_time(uptime_stdout),
      uptime_users: parse_uptime_users(uptime_stdout),
      uptime_load: parse_uptime_load(uptime_stdout),
    }
    broadcast_state(state)
    {:noreply, state}
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

  # Internal API
  defp query_datetime() do
    {out, status} = System.cmd("date", [])
    out |> String.trim()
  end

  defp query_uptime() do
    {out, status} = System.cmd("uptime", [])
    out
  end

  defp parse_uptime_time(uptime_stdout) do
    uptime_stdout  |> String.trim() |> String.split("user") |> List.first() |> String.split(",") |> Enum.drop(-1) |> Enum.join(",")
  end

  defp parse_uptime_users(uptime_stdout) do
    uptime_stdout |> String.trim()|> String.split("user") |> List.first() |> String.split(",") |> List.last()
  end

  defp parse_uptime_load(uptime_stdout) do
    uptime_stdout |> String.trim()|> String.split("load averages:") |> List.last() #|> String.split(",") |> List.last()
  end

  defp query_hostname() do
    {out, status} = System.cmd("hostname", [])
    out |> String.trim()
  end
end
