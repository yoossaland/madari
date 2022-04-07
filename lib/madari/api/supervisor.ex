defmodule Madari.Api.Supervisor do
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Madari.Api.Notification, [[name: Madari.Api.Notification]]),
      worker(Madari.Api.Sysinfo, [[name: Madari.Api.Sysinfo]]),
      worker(Madari.Api.Bootenv, [[name: Madari.Api.Bootenv]]),
      worker(Madari.Api.Logs.Syslog, [[name: Madari.Api.Logs.Syslog]]),
      worker(Madari.Api.Logs.StreamFile, [%{name: :messages, topic: "syslog", logfile: "/var/log/messages"}]),
      worker(Madari.Api.Logs.StreamFile, [%{name: :syncthing, topic: "syslog", logfile: "/var/log/syncthing.log"}], id: :syncthing),
      worker(Madari.Api.Logs.StreamFile, [%{name: :dmesg, topic: "syslog", logfile: "/var/log/dmesg.today"}], id: :dmesg),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
