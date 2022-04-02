defmodule MadariWeb.HomeLive do
  use Phoenix.LiveView
  alias Phoenix.LiveView.JS
  alias Madari.Api.Sysinfo
  import Madari.Bulma

  def mount(_params, _session, socket) do
    if connected?(socket), do: Sysinfo.subscribe()
    {:ok, socket |> assign(%{
      sysinfo: Sysinfo.state(),
      button_text: "Click Me",
    })}
  end

  def handle_info({:sysinfo, sysinfo}, socket) do
    {:noreply, socket |> assign(%{
      sysinfo: sysinfo,
    })}
  end


  def toggle_host_info(js \\ %JS{}) do
    js
    |> JS.toggle(to: "#host-info")
  end

  def handle_event("whoa", %{"value" => ""}, socket) do
    :timer.sleep(850)
    {:noreply, socket |> assign(%{
      button_text: "WHOA!",
    })}
  end
  # def columns(assigns) do
  #   ~H"""
  #   <div class="columns">
  #     <%= render_slot(@inner_block) %>
  #   </div>
  #   """
  # end

end
