defmodule Madari.LiveComponents.HealthIcon do
  use Phoenix.LiveComponent
  alias Madari.Api.Sysinfo
  alias MadariWeb.Router.Helpers, as: Routes

  @default %{
    name: "heart-circle-minus",
    color: "#aaa",
    text: "",
  }

  def update(assigns, socket) do
    {:ok, socket |> assign(%{health_icon: @default})}
  end

  def render(assigns) do
    ~H"""
    <a class="navbar-item" href="#">
      <FontAwesome.LiveView.icon name={@health_icon[:name]}
        opts={[aria_hidden: true, height: "16px", fill: @health_icon[:color],
        style: "margin-right: -.75rem;"]} />
      <%= live_patch @health_icon[:text],
        to: Routes.live_path(@socket, MadariWeb.HomeLive),
        class: "navbar-item" %>
    </a>
    """
  end
end
