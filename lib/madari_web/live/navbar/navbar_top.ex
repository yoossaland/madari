defmodule MadariWeb.Navbar.Top do
  use Phoenix.LiveView
  alias Phoenix.LiveView.JS
  # alias Madari.Api.Sysinfo
  alias MadariWeb.Router.Helpers, as: Routes
  import Madari.Bulma

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
      to: "#navbar-top-menu.is-active"
    )
    |> JS.add_class(
      "is-active",
      to: "#navbar-top-menu:not(.is-active)"
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
    <nav id="navbar-top" class="navbar is-fixed-top is-warning">
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

      <div id="navbar-top-menu" class="navbar-menu">
        <div class="navbar-start">

          <div class="navbar-item has-dropdown is-hoverable">
            <.navbar_link icon="server">
              Host
            </.navbar_link>

            <div class="navbar-dropdown">
              <.navbar_item icon="download">
                Software Updates
              </.navbar_item>

              <.navbar_item icon="clock-rotate-left">
                <%= live_patch "Boot Environments",
                  to: Routes.live_path(@socket, MadariWeb.BootenvLive)
                %>
              </.navbar_item>

              <.navbar_item icon="rotate-left">
                <%= live_patch "Reboot",
                  to: Routes.live_path(@socket, MadariWeb.RebootLive)
                %>
              </.navbar_item>
            </div>
          </div>

          <div class="navbar-item has-dropdown is-hoverable">
            <.navbar_link icon="microchip">
              Compute
            </.navbar_link>

            <div class="navbar-dropdown">
              <.navbar_item icon="terminal">
                Terminals
              </.navbar_item>
            </div>
          </div>

          <div class="navbar-item has-dropdown is-hoverable">
            <.navbar_link icon="hard-drive">
              Storage
            </.navbar_link>

            <div class="navbar-dropdown">
              <.navbar_item icon="cloud-arrow-up">
                Backups
              </.navbar_item>
            </div>
          </div>

          <div class="navbar-item has-dropdown is-hoverable">
            <.navbar_link icon="network-wired">
              Network
            </.navbar_link>

            <div class="navbar-dropdown">
              <.navbar_item icon="shield-halved">
                VPN
              </.navbar_item>
            </div>
          </div>

        </div>

        <div class="navbar-end">
          <.navbar_item icon="screwdriver-wrench">
            Preferences
          </.navbar_item>

          <.navbar_item icon="file-lines">
            Logs
          </.navbar_item>
        </div>
      </div>
    </nav>
    """
  end
end
