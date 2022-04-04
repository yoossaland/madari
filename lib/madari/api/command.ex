defmodule Madari.Api.Command do
  def execute(cmd, args) do
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
