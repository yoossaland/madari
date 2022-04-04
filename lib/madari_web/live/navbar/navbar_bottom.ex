defmodule MadariWeb.Navbar.Bottom do
  use Phoenix.LiveView
  alias Phoenix.LiveView.JS

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

  def toggle_burger_menu(js \\ %JS{}) do
    js
    |> JS.remove_class(
      "is-active",
      to: "#navbar-bottom.is-active"
    )
    |> JS.add_class(
      "is-active",
      to: "#navbar-bottom:not(.is-active)"
    )
    |> JS.remove_class(
      "is-active",
      to: "#navbar-bottom-burger.is-active"
    )
    |> JS.add_class(
      "is-active",
      to: "#navbar-bottom-burger:not(.is-active)"
    )
  end

  def render(assigns) do
    ~H"""
      <nav class="navbar is-transparent is-fixed-bottom is-dark">
        <div class="navbar-brand">
            <div class="field has-addons navbar-item" style="margin: 0; min-width: calc(100vw - .75rem);">
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
      </nav>
      """
  end
end
