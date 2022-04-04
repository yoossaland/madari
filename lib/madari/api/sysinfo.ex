defmodule Madari.Api.Sysinfo do
  use GenServer
  use Timex
  alias Madari.Api.Sysrc
  alias Freedive.Api.Bootenv

  @name __MODULE__
  @topic "sysinfo"

  # Client
  def start_link(_args) do
    GenServer.start_link(@name, [], name: @name)
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

  # Server
  @impl true
  def init(state) do
    Process.send_after(self(), :update_state, 1)
    {:ok, state}
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
  def handle_info(:update_state, _state) do
    {boottime_sec, _} = Integer.parse(Madari.Api.Sysctl.boottime())
    boottime = DateTime.from_unix!(boottime_sec, :second, Calendar.ISO)
    boottime = DateTime.shift_zone!(boottime, "Etc/UTC", Calendar.UTCOnlyTimeZoneDatabase)
    boottime = Calendar.strftime(boottime, "%A, %B %d %Y %I:%M %p")
    uptime = Timex.parse!(boottime, "%A, %B %d %Y %I:%M %p", :strftime)
      |> Timex.format!("{relative}", :relative)
      |> String.replace(" ago", "")
    state = %{
      hostname: sysctl_read("kern.hostname"),
      ostype: sysctl_read("kern.ostype"),
      osrelease: sysctl_read("kern.osrelease"),
      osrevision: sysctl_read("kern.osrevision"),
      boottime: boottime,
      uptime: uptime,
      disks: sysctl_read("kern.disks"),
      loadavg: sysctl_read("vm.loadavg"),
      machine: sysctl_read("hw.machine"),
      model: sysctl_read("hw.model"),
      ncpu: sysctl_read("hw.ncpu"),
      physmem: sysctl_read("hw.physmem"),
      bootmethod: sysctl_read("machdep.bootmethod"),
      datetime: query_datetime(),
      be_default: Sysrc.read("default_be", "/madari/madari.conf"),
      be_current: Bootenv.be_current(),
      be_fallback: Bootenv.be_fallback(),
      top_raw: query_top(),
      zfs_list_raw: query_zfs_list(),
      zpool_list_raw: query_zpool_list(),
    }
    broadcast({:sysinfo, state})
    Process.send_after(self(), :update_state, 5000)
    {:noreply, state}
  end

  # Internal API
  defp sysctl_read(oid) do
    Madari.Api.Sysctl.read(oid)
  end

  defp query_datetime() do
    {out, _status} = System.cmd("date", [])
    out |> String.trim()
  end

  defp query_be_current() do
    {out, _status} = System.cmd("date", [])
    out |> String.trim()
  end

  defp query_top() do
    {out, status} = execute("top", ["-b"])
    out
  end

  defp query_zfs_list() do
    {out, status} = execute("zfs", ["list"])
    out
  end

  defp query_zpool_list() do
    {out, status} = execute("zpool", ["list"])
    out
  end


  defp execute(cmd, args) do
    if is_root_user() do
      {out, status} = System.cmd(cmd, args)
      {
        out |> String.trim(),
        status
      }
    else
      {out, status} = System.cmd("doas", [cmd] ++ args)
      {
        out |> String.trim(),
        status
      }
    end
  end

  defp is_root_user() do
    {out, status} = System.cmd("whoami", [])
    out |> String.trim() |> String.equivalent?("root")
  end
end
