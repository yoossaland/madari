defmodule Madari.Api.Sysrc do
  alias Madari.Api.Command

  def read(key, file \\ "/etc/rc.conf") do
    {out, status} = Command.execute("sysrc", ["-n", "-f", file, key])
    case status do
      0 -> out |> String.trim() |> String.replace("'", "")
      _ -> "Uknown variable: #{key}"
    end
  end

  def write(key, value, file \\ "/etc/rc.conf") do
    {out, status} = Command.execute("sysrc", ["-n", "-f", file, "#{key}='#{value}'"])
    if status != 0 do
      IO.puts(out)
      IO.inspect(key)
      IO.inspect(value)
    end
    status
  end
end
