defmodule MadariWeb.Navbar.Bottom do
  use Phoenix.LiveView
  alias Madari.Api.Sysinfo
  alias MadariWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    if connected?(socket), do: Sysinfo.subscribe()
    {:ok, socket |> assign(%{
      sysinfo: Sysinfo.state(),
      icon_style: "heart-circle-check",
      icon_fill_color: "#5c5",
      icon_description: "Healthy",
    })}
  end

  def handle_info({:sysinfo, sysinfo}, socket) do
    {load, _} = sysinfo[:uptime_load] |> String.split(",") |> List.first() |> String.trim() |> Float.parse()
    IO.inspect(load)
    if load > 1.0 do
      if load > 2.0 do
        {:noreply, socket |> assign(%{
          icon_style: "heart-circle-xmark",
          icon_fill_color: "#c55",
          icon_description: "Degraded",
          sysinfo: sysinfo,
        })}
      else
        {:noreply, socket |> assign(%{
          icon_style: "heart-circle-exclamation",
          icon_fill_color: "#cc5",
          icon_description: "Stressed",
          sysinfo: sysinfo,
        })}
      end
    else
      {:noreply, socket |> assign(%{
        icon_style: "heart-circle-check",
        icon_fill_color: "#5c5",
        icon_description: "Healthy",
        sysinfo: sysinfo,
      })}
    end
  end

  def render(assigns) do
    ~H"""
      <nav class="navbar is-transparent is-fixed-bottom is-dark">
        <div class="navbar-brand">
          <a class="navbar-item" href="#">
            <FontAwesome.LiveView.icon name={@icon_style}
              opts={[aria_hidden: true, height: "16px", fill: @icon_fill_color,
              style: "margin-right: -.75rem;"]} />
            <%= live_patch @icon_description,
              to: Routes.live_path(@socket, MadariWeb.HomeLive),
              class: "navbar-item" %>
          </a>
          <div class="navbar-burger" data-target="navbarExampleTransparentExample">
            <span></span>
            <span></span>
            <span></span>
          </div>
        </div>

        <div id="navbarExampleTransparentExample" class="navbar-menu">
          <div class="navbar-start">
            <a class="navbar-item" href="#">
              <%= @sysinfo[:uptime_load] %>
            </a>
          </div>

          <div class="navbar-end">
            <a class="navbar-item" href="#">
              Services
            </a>
            <a class="navbar-item" href="#">
              Tasks
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
