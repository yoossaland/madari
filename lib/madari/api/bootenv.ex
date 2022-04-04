defmodule Madari.Api.Bootenv do
  use GenServer
  alias Madari.Api.Sysrc
  alias Madari.Api.Command
  alias Madari.Api.Notification

  @name __MODULE__
  @topic "bootenv"
  @refresh_delay 12000

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

  def list do
    GenServer.call(@name, :list)
  end

  def current do
    GenServer.call(@name, :current)
  end

  def default do
    GenServer.call(@name, :default)
  end

  def fallback do
    GenServer.call(@name, :fallback)
  end

  def next do
    GenServer.call(@name, :next)
  end

  def is_default?(name) do
    GenServer.call(@name, {:is_default, name})
  end

  def search(query) do
    GenServer.call(@name, {:search, query})
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Madari.PubSub, @topic)
  end

  def set_be_next(name) do
    GenServer.cast(@name, {:set_be_next, name})
  end

  def create(name) do
    GenServer.cast(@name, {:create, name})
  end

  def get(name) do
    GenServer.call(@name, {:get, name})
  end

  def set_be_default(name) do
    GenServer.cast(@name, {:set_be_default, name})
  end

  def set_be_fallback(name) do
    GenServer.cast(@name, {:set_be_fallback, name})
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
    Process.send_after(self(), :boot_ok, 10000)
    {:ok, state}
  end

  @impl true
  def handle_cast({:broadcast, frame}, state) do
    Phoenix.PubSub.broadcast(Madari.PubSub, @topic, frame)
    {:noreply, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def raw_be_list do
    # default_in_rc = Porcelain.shell("sysrc -qn madari_be_default").out |> String.trim()
    default_in_rc = Sysrc.read("default_be", "/madari/madari.conf")

    # std = Porcelain.shell("bectl list -H")
    {out, _status} = Command.execute("bectl", ["list", "-H"])

    out
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn line -> String.split(line, "\t") end)
      |> Enum.map(
        fn [name, flags, mountpoint, space, creation] ->
          %{
            name: name,
            flags: flags,
            mountpoint: mountpoint,
            space: space,
            creation: creation,
            is_fallback: String.contains?(flags, "R"),
            is_current: String.contains?(flags, "N"),
            is_next: String.contains?(flags, "T"),
            is_default: String.equivalent?(name, default_in_rc),
          }
        end)
  end

  @impl true
  def handle_info(:boot_ok, state) do
    # default_in_rc = Porcelain.shell("sysrc -qn madari_be_default").out |> String.trim()
    default_in_rc = Sysrc.read("default_be", "/madari/madari.conf")
    be_list = raw_be_list()
    current_be = be_list |> Enum.filter( fn be -> String.contains?(be[:flags], "N") end) |> List.first()
    default_be = be_list |> Enum.filter( fn be -> String.equivalent?(be[:name], default_in_rc)  end) |> List.first()
    fallback_be = be_list |> Enum.filter( fn be -> String.contains?(be[:flags], "R") end) |> List.first()
    if default_be != nil and current_be[:name] == default_be[:name] do
      # _std = Porcelain.shell("bectl activate -t #{current_be[:name]}")
      {out, _status} = Command.execute("bectl", ["activate", "-t", current_be[:name]])
      Notification.send("Madari is Online", "Booted into default BE: #{current_be[:name]}", 1)
      {:noreply, state}
    else
      if current_be[:name] == fallback_be[:name] do
        Notification.send("Madari is Online", "Booted into fallback BE: #{current_be[:name]}", 1)
        {:noreply, state}
      else
        Notification.send("Madari is Online", "Booted into temporary BE: #{current_be[:name]}", 1)
        {:noreply, state}
      end
    end
  end

  @impl true
  def handle_info(:update_state, _state) do
    # default_in_rc = Porcelain.shell("sysrc -qn madari_be_default").out |> String.trim()
    default_in_rc = Sysrc.read("default_be", "/madari/madari.conf")
    be_list = raw_be_list()
    current_be = be_list |> Enum.filter( fn be -> String.contains?(be[:flags], "N") end) |> List.first()
    fallback_be = be_list |> Enum.filter( fn be -> String.contains?(be[:flags], "R") end) |> List.first()
    default_be = be_list |> Enum.filter( fn be -> String.equivalent?(be[:name], default_in_rc)  end) |> List.first()
    next_be = be_list |> Enum.filter( fn be -> String.contains?(be[:flags], "T") end) |> List.first()

    state = %{
      be_list: be_list,
      current: current_be,
      default: default_be,
      fallback: fallback_be,
      next: next_be,
    }
    broadcast_state(state)

    Process.send_after(self(), :update_state, @refresh_delay)
    {:noreply, state}
  end

  @impl true
  def handle_call(:is_available, _from, state) do
    {:reply, true, state}
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state[:be_list], state}
  end

  @impl true
  def handle_call(:current, _from, state) do
    {:reply, state[:current], state}
  end

  @impl true
  def handle_call(:default, _from, state) do
    {:reply, state[:default], state}
  end

  @impl true
  def handle_call(:fallback, _from, state) do
    {:reply, state[:fallback], state}
  end

  @impl true
  def handle_call(:next, _from, state) do
    {:reply, state[:next], state}
  end

  @impl true
  def handle_call({:get, name}, _from, state) do
    be = state[:be_list]
      |> Enum.filter(fn b -> b.name == name end) |> List.first()
    {:reply, be, state}
  end

  @impl true
  def handle_call({:is_default, name}, _from, state) do
    next = if state[:next] != nil do state[:next].name else "" end
    # IO.puts("name: #{name}, next: #{next}")
    if name == next do
      # default_in_rc = Porcelain.shell("sysrc -qn madari_be_default").out |> String.trim()
      default_in_rc = Sysrc.read("default_be", "/madari/madari.conf")
      # IO.puts(default_in_rc)
      # default_in_rc = std.out |> String.trim()
      {:reply, default_in_rc == name, state}
    else
      {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:search, query}, _from, state) do
    result =
      state[:be_list]
      |> Enum.filter( fn be -> String.starts_with?(be[:name], query) end)

    {:reply, result, state}
  end

  @impl true
  def handle_cast({:create, name}, state) do
    # std = Porcelain.shell("bectl create -r #{name}")
    {out, status} = Command.execute("bectl", ["create", "-r", name])
    if status != 0 do
      IO.inspect(out)
    else
      Process.send_after(self(), :update_state, 1)
    end
    {:noreply, state}
  end

  @impl true
  def handle_cast({:set_be_next, name}, state) do
    option = if state[:next] != nil and state[:next].name == name do "-T" else "-t" end
    # std = Porcelain.shell("bectl activate #{option} #{name}")
    {out, status} = Command.execute("bectl", ["activate", option, name])
    if status != 0 do
      IO.inspect(out)
    else
      Process.send_after(self(), :update_state, 1)
    end
    {:noreply, state}
  end

  @impl true
  def handle_cast({:set_be_default, name}, state) do
    # std = Porcelain.shell("bectl activate -t #{name}")
    # std = Porcelain.shell("sysrc madari_be_default='#{name}'")
    {out, _status} = Command.execute("bectl", ["activate", "-t", name])
    default_in_rc = Sysrc.write("default_be", name, "/madari/madari.conf")
    if default_in_rc != 0 do
      IO.inspect(out)
    else
      Process.send_after(self(), :update_state, 1)
    end
    {:noreply, state}
  end

  @impl true
  def handle_cast({:set_be_fallback, name}, state) do
    # std = Porcelain.shell("bectl activate #{name}")
    {out, status} = Command.execute("bectl", ["activate", name])
    if status != 0 do
      IO.inspect(out)
    else
      Process.send_after(self(), :update_state, 1)
    end
    {:noreply, state}
  end
end
