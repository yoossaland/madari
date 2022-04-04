defmodule MadariWeb.RebootLive do
  use Phoenix.LiveView
  alias Phoenix.LiveView.JS
  alias Madari.Api.Reboot
  alias Madari.Api.Bootenv
  alias Madari.Api.Command

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :uptime, 10000)
    {:ok, socket |> assign(%{
      confirm: :false,
      rebooting: false,
      be_current: Bootenv.current(),
      be_default: Bootenv.default(),
      be_fallback: Bootenv.fallback(),
      be_next: Bootenv.next(),
      host_name: host_name(),
      uptime: uptime(),
      })}
  end

  def handle_info(:uptime, socket) do
    if connected?(socket), do: Process.send_after(self(), :uptime, 10000)
    {:noreply, socket |> assign(%{uptime: uptime()})}
  end

  def handle_info(:remove_confirm_prompt, socket) do
    {:noreply, socket |> assign(%{confirm: :false})}
  end

  def handle_event("reboot", %{"value" => ""}, socket) do
    if connected?(socket), do: Process.send_after(self(), :remove_confirm_prompt, 5000)
    {:noreply, socket |> assign(%{confirm: :true})}
  end

  def handle_event("confirm_reboot", %{"value" => ""}, socket) do
    Reboot.reboot()
    {:noreply, socket |> assign(%{rebooting: true})}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def uptime() do
    {stdout, _} = Command.execute("uptime", [])
    String.trim(stdout)
  end

  def host_name() do
    {stdout, _} = Command.execute("hostname", [])
    String.trim(stdout)
  end

end
