defmodule Madari.Api.Logs.StreamFile do
  use GenServer
  alias Porcelain.Process, as: Proc
  alias Porcelain.Result

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
    # Registry.register()
  end

  def init(args) do
    {:ok, args, {:continue, :stream_start}}
  end

  def handle_continue(:stream_start, state) do
    log_path = Path.absname(state[:logfile])
    {:ok, fs_pid} = FileSystem.start_link([dirs: [log_path], name: state[:name]])
    FileSystem.subscribe(fs_pid)
    fp = File.open!(log_path, [:read])
    :file.position(fp, :eof)
    state = state |> Map.merge(%{fp: fp, fs_pid: fs_pid})
    {:noreply, state}
  end

  def handle_info({:file_event, fs_pid, :stop}, %{fs_pid: fs_pid, fp: fp}=state) do
    IO.inspect({:file_event, fs_pid, :stop})
    {:noreply, state}
  end

  def handle_info({:file_event, fs_pid, {path, events}}, state) do
    if events == [:modified] do
      state[:fp] |> tail |> broadcast
    end
    {:noreply, state}
  end

  def handle_info(:reopen_log_file, state) do
    IO.puts("!!! reopening log file")
    File.close(state[:fp])
    Process.exit(state[:fs_pid], :kill)
    :timer.sleep(300)
    log_path = Path.absname(state[:logfile])
    {:ok, fs_pid} = FileSystem.start_link([dirs: [log_path], name: state[:name]])
    {:ok, fp} = File.open(state[:logfile], [:read])
    :file.position(fp, :eof)
    {:noreply, state |> Map.replace!(:fp, fp)}
  end

  def handle_info({:broadcast, logs}, state) do
    Phoenix.PubSub.broadcast(Madari.PubSub, state[:topic], {state[:name], logs})
    {:noreply, state}
  end

  defp tail(fp) do
    tail(IO.binread(fp, :line), fp, [])
  end
  defp tail(:eof, _fp, buffer) do
    buffer
  end
  defp tail(line, fp, buffer) do
    tail(IO.binread(fp, :line), fp, buffer ++ [line])
  end

  defp broadcast([]) do
    :ok
  end
  defp broadcast(lines) do
    logs = lines
      |> Enum.map(fn line ->
        id = :crypto.hash(:md5, line) |> Base.encode16(case: :lower)
        if line |> String.contains?("logfile turned over") do
          Process.send_after(self(), :reopen_log_file, 1)
        end
        %{id: id, message: line |> String.trim}
      end)
    Process.send(self(), {:broadcast, logs}, [])
  end

end
