defmodule MadariWeb.HomeLive do
  use Phoenix.LiveView
  alias Madari.Api.Sysinfo

  def mount(_params, _session, socket) do
    if connected?(socket), do: Sysinfo.subscribe()
    {:ok, socket |> assign(%{
      sysinfo: Sysinfo.state(),
    })}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_info({:sysinfo, sysinfo}, socket) do
    {:noreply, socket |> assign(%{sysinfo: sysinfo})}
  end
end
