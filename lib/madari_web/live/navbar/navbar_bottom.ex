defmodule MadariWeb.Navbar.Bottom do
  use Phoenix.LiveView
  alias Madari.Api.Sysinfo
  alias MadariWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    if connected?(socket), do: Sysinfo.subscribe()
    {:ok, socket |> assign(%{
      sysinfo: %{},
    })}
  end

  def handle_info({:sysinfo, sysinfo}, socket) do
    {:noreply, socket |> assign(%{
      sysinfo: sysinfo,
    })}
  end

  def render(assigns) do
    # <.live_component
    # module={Madari.LiveComponents.HealthIcon}
    # id="health_icon" sysinfo={assigns[:sysinfo]}/>

    ~H"""
      <nav class="navbar is-transparent is-fixed-bottom is-dark">
        <div class="navbar-brand">
        <div class="navbar-burger" data-target="navbarExampleTransparentExample">
            <span></span>
            <span></span>
            <span></span>
          </div>
        </div>

        <div id="navbarExampleTransparentExample" class="navbar-menu">
          <div class="navbar-start">
          </div>

          <div class="navbar-end">
            <a class="navbar-item" href="#">
              Tasks
            </a>
            <a class="navbar-item" href="#">
              Services
            </a>
            <a class="navbar-item" href="#">
              Utilities
            </a>
            <a class="navbar-item" href="#">
              Terminal
            </a>
            <div class="field has-addons navbar-item" style="margin: 0;">
              <div class="control is-expanded">
                <input class="input is-small is-fullwidth" type="text" placeholder="Find a repository">
              </div>
              <div class="control">
                <a class="button is-warning is-small">
                  Search
                </a>
              </div>
            </div>
          </div>

        </div>
      </nav>
      """
  end
end
