defmodule Madari.Bulma do
  use Phoenix.Component
  use Phoenix.HTML
  alias Phoenix.LiveView.JS

  def toggle_host_info(id, js \\ %JS{}) do
    js
    |> JS.toggle(to: "##{id}-content")
  end

  def columns(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
    ~H"""
    <div class={"columns #{@class}"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def column(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <div class={"column #{@class}"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def block(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <div class={"block #{@class}"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def content(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <div class={"content #{@class}"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def title(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <h3 class={"title #{@class}"}>
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end

  def subtitle(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <h5 class={"subtitle #{@class}"}>
      <%= render_slot(@inner_block) %>
    </h5>
    """
  end

  def icon(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:icon, fn -> nil end)
      |> assign_new(:icon_color, fn -> "#333" end)
      |> assign_new(:size, fn -> "default" end)

    ~H"""
    <span class={"icon #{@class} is-#{@size}"}>
      <FontAwesome.LiveView.icon name={@icon} opts={[aria_hidden: true, height: "60%", fill: @icon_color]}/>
    </span>
    """
  end

  def card(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:closed, fn -> nil end)

    ~H"""
    <div class="card" id={"#{@id}-card"}>
      <header class="card-header" id={"#{@id}-header"} phx-click={toggle_host_info(@id)}}
        style="background-color: #eee;">
        <p class="card-header-title">
          <%= render_slot(@header) %>
        </p>
        <button class="card-header-icon" aria-label="more options">
          <span class="icon">
            <FontAwesome.LiveView.icon name={@icon}
              opts={[aria_hidden: true, height: "20px", fill: @icon_color]}/>
          </span>
        </button>
      </header>
      <div class="card-content" id={"#{@id}-content"} style={if @closed do "display: none;" else "" end}>
        <%= render_slot(@content) %>
      </div>
    </div>
    """
  end

  def buttons(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <button class={"buttons #{@class}"}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def delete(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:click, fn -> "" end)

    ~H"""
    <button class={"delete #{@class}"} phx-click={@click} phx-disable-with="is-loading"></button>
    """
  end

  def button(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:click, fn -> "" end)
      |> assign_new(:disabled, fn -> false end)
      |> assign_new(:icon, fn -> nil end)
      |> assign_new(:icon_color, fn -> "#333" end)
      |> assign_new(:size, fn -> "default" end)
      |> assign_new(:inner_block, fn -> nil end)

    ~H"""
    <button class={"button #{@class} is-#{@size}"} phx-click={@click} phx-disable-with="On it!" disabled={@disabled}>
      <%= if @icon do %>
      <span class="icon is-#{@size}">
        <FontAwesome.LiveView.icon name={@icon} opts={[aria_hidden: true, height: "60%", fill: @icon_color]}/>
      </span>
      <%= if @inner_block do %>
        <span>
          <%= render_slot(@inner_block) %>
        </span>
      <% end %>
      <% else %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </button>
    """
  end

  def button_link(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:click, fn -> "" end)
      |> assign_new(:disabled, fn -> false end)

    ~H"""
    <a class={"button #{@class}"} href={@href} title={@title} phx-click={@click} phx-disable-with="is-loading" disabled={@disabled}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  def button_submit(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:click, fn -> "" end)
      |> assign_new(:disabled, fn -> false end)

    ~H"""
    <input class={"button #{@class}"} type="submit" value={@inner_content}  phx-click={@click} phx-disable-with="is-loading" disabled={@disabled} />
    """
  end

  def button_reset(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:click, fn -> "" end)
      |> assign_new(:disabled, fn -> false end)

    ~H"""
    <input class={"button #{@class}"} type="reset" value={@inner_content}  phx-click={@click} phx-disable-with="is-loading" disabled={@disabled} />
    """
  end

end
