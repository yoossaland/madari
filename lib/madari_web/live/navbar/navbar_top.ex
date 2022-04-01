defmodule MadariWeb.Navbar.Top do
  use Phoenix.LiveView
  alias Phoenix.LiveView.JS
  # alias Madari.Api.Sysinfo
  alias MadariWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    # if connected?(socket), do: Sysinfo.subscribe()
    {:ok, socket |> assign(%{
      # sysinfo: Sysinfo.state(),
    })}
  end

  def handle_info({:sysinfo, sysinfo}, socket) do
    {:noreply, socket |> assign(%{sysinfo: sysinfo})}
  end

  def toggle_burger_menu(js \\ %JS{}) do
    js
    |> JS.remove_class(
      "is-active",
      to: "#navbar-top.is-active"
    )
    |> JS.add_class(
      "is-active",
      to: "#navbar-top:not(.is-active)"
    )
    |> JS.remove_class(
      "is-active",
      to: "#navbar-top-burger.is-active"
    )
    |> JS.add_class(
      "is-active",
      to: "#navbar-top-burger:not(.is-active)"
    )
  end

  def render(assigns) do
    ~H"""
    <nav class="navbar is-fixed-top is-warning">
      <div class="navbar-brand">
        <%= live_patch "Madari",
          to: Routes.live_path(@socket, MadariWeb.HomeLive),
          class: "navbar-item subtitle",
          style: "color: #000; margin: 0; padding: 0 .75rem;"
        %>
        <div class="navbar-burger" id="navbar-top-burger" phx-click={toggle_burger_menu()}>
          <span></span>
          <span></span>
          <span></span>
        </div>
      </div>

      <div id="navbar-top" class="navbar-menu">
        <div class="navbar-start">
          <a class="navbar-item" href="#">
            <span class="icon">
              <FontAwesome.LiveView.icon name="microchip" opts={[aria_hidden: true, height: "18px", fill: "#555"]} />
            </span>
            <span>Compute</span>
          </a>
          <a class="navbar-item" href="#">
            <span class="icon">
              <FontAwesome.LiveView.icon name="hard-drive" opts={[aria_hidden: true, height: "16px", fill: "#555"]} />
            </span>
            <span>Storage</span>
          </a>
          <a class="navbar-item" href="#">
            <span class="icon">
              <FontAwesome.LiveView.icon name="network-wired" opts={[aria_hidden: true, height: "16px", fill: "#555"]} />
            </span>
            <span>Network</span>
          </a>
        </div>

        <div class="navbar-end">
          <a class="navbar-item" href="#">
            <span class="icon">
              <FontAwesome.LiveView.icon name="bell" opts={[aria_hidden: true, height: "16px", fill: "#555"]} />
            </span>
            <span>Alerts</span>
          </a>
          <a class="navbar-item" href="#">
            <span class="icon">
              <FontAwesome.LiveView.icon name="chart-simple" opts={[aria_hidden: true, height: "16px", fill: "#555"]} />
            </span>
            <span>Metrics</span>
          </a>
          <a class="navbar-item" href="#">
            <span class="icon">
              <FontAwesome.LiveView.icon name="file-lines" opts={[aria_hidden: true, height: "16px", fill: "#555"]} />
            </span>
            <span>Logs</span>
          </a>
        </div>
      </div>
    </nav>
    """
  end
end
