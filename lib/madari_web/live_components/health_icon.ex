defmodule Madari.LiveComponents.HealthIcon do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="box">
      <%= @content %>
      <br />
      <%= @content %>
      <br />
      <%= @content %>
      <br />
      <%= @content %>
      <br />
      <%= @content %>
      <br />
      <%= @content %>
    </div>
    """
  end
end
