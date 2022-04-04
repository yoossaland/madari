defmodule Madari.Api.Reboot do
  alias Madari.Api.Notification

  def reboot() do
    Notification.send("Rebooting", "rebooting...", 1)
    {stdout, _} = System.cmd("shutdown", ["-r", "now"])
    stdout |> String.trim()
  end
end
