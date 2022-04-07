defmodule MadariWeb.LogsLive do
  use Phoenix.LiveView
  alias Phoenix.LiveView.JS
  alias Madari.Api.Logs.Syslog
  import Madari.Bulma

  def mount(_params, _session, socket) do
    if connected?(socket), do: Syslog.subscribe()
    {:ok, socket |> assign(
      %{
        hello: Syslog.state()[:hello],
        log_stream: [],
      }),
      temporary_assigns: [log_stream: []]
    }
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end


  def handle_info({:state, state}, socket) do
    {:noreply, socket |> assign(%{
      hello: state[:hello],
    })}
  end

  @impl true
  def handle_info({:messages, logs}, socket) do
    {:noreply, socket |> assign(%{
      log_stream: logs,
    })}
  end

  @impl true
  def handle_info({:syncthing, logs}, socket) do
    {:noreply, socket |> assign(%{
      log_stream: logs,
    })}
  end

end
