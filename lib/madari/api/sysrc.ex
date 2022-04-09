defmodule Madari.Api.Sysrc do
  alias Madari.Api.Command

  def all(file \\ "/etc/rc.conf") do
    {out, status} = Command.execute("sysrc", ["-a", "-f", file])
    case status do
      0 -> out
            |> String.trim()
            |> String.replace("'", "")
            |> String.split("\n")
            |> Enum.map(fn line ->
              t = String.split(line, ":")
              %{
                key: List.first(t) |> String.trim,
                value: List.last(t) |> String.trim,
              }
            end)
      _ -> raise out
    end
  end

  def descriptions(file \\ "/etc/rc.conf") do
    {out, status} = Command.execute("sysrc", ["-a", "-d", "-f", file])
    case status do
      0 -> out
            |> String.trim()
            # |> String.replace("'", "")
            |> String.split("\n")
            |> Enum.map(fn line ->
              t = String.split(line, ":")
              %{
                key: List.first(t) |> String.trim,
                value: List.last(t) |> String.trim,
              }
            end)
            |> List.flatten()
      _ -> raise out
    end
  end

  def descriptions_map(file \\ "/etc/rc.conf") do
    {out, status} = Command.execute("sysrc", ["-a", "-d", "-f", file])
    case status do
      0 -> out
            |> String.trim()
            # |> String.replace("'", "")
            |> String.split("\n")
            |> Enum.map(fn line ->
              t = String.split(line, ":")
              key = List.first(t) |> String.trim
              value = List.last(t) |> String.trim
              [key, value]
            end)
            |> Enum.into(%{}, fn [key, value] -> {key, value} end)
      _ -> raise out
    end
  end

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
