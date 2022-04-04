defmodule Madari.Api.Sysrc do
  def read(key, file \\ "/etc/rc.conf") do
    {out, status} = System.cmd("sysrc", ["-n", "-f", file, key])
    case status do
      0 -> out |> String.trim()
      _ -> "Uknown variable: #{key}"
    end
  end
end
