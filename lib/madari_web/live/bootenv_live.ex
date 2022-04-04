defmodule MadariWeb.BootenvLive do
  use Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Madari.Api.Bootenv

  def mount(_params, _session, socket) do
    if connected?(socket), do: Bootenv.subscribe()
    {:ok, socket |> assign(%{
      be_available: Bootenv.is_available?,
      be_list: Bootenv.list,
      be_selected: Bootenv.current.name,
      be_editing: nil,
      query: "",
      result: nil,
      be_editing_name: "",
    })}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_info({:state, state}, socket) do
    if socket.assigns[:query] do
      result = Bootenv.search(socket.assigns[:query])
      {:noreply, socket |> assign(%{be_list: result})}
    else
      {:noreply, socket |> assign(%{be_list: state[:be_list]})}
    end
  end

  def handle_event("select_be", %{"name" => name}, socket) do
    {:noreply, socket |> assign(%{
      be_selected: name,
    })}
  end

  def handle_event("next_be", %{"name" => name}, socket) do
    Bootenv.set_be_next(name)
    {:noreply, socket}
  end

  def handle_event("default_be", %{"name" => name}, socket) do
    Bootenv.set_be_default(name)
    {:noreply, socket}
  end

  def handle_event("fallback_be", %{"name" => name}, socket) do
    Bootenv.set_be_fallback(name)
    {:noreply, socket}
  end

  def handle_event("search", %{"q" => query}, socket) do
    result = Bootenv.search(query)
    {:noreply, socket |> assign(%{be_list: result, query: query})}
  end

  def handle_event("edit_or_create", %{"q" => query}, socket) do
    result = socket.assigns[:be_list]
    select = socket.assigns[:be_list] |> List.first()
    if length(result) == 0 do
      Bootenv.create(query)
      {:noreply, socket |> assign(%{be_selected: query, query: query})}
    else
      name = select.name
      {:noreply, socket |> assign(%{
        be_selected: name,
        query: name,
        # be_editing: Bootenv.get(name),
        # be_editing_name: name,
      })}
    end
  end

  def handle_event("edit_be", %{"name" => name}, socket) do
    {:noreply, socket |> assign(%{
      be_selected: name,
      query: name,
      be_editing: Bootenv.get(name),
      be_editing_name: name,
      })}
  end

  def handle_event("be_editing_close", %{}, socket) do
    {:noreply, socket |> assign(%{
      query: "",
      be_editing: nil,
      be_editing_name: "",
      be_list: Bootenv.list,
      })}
  end

  def handle_event("be_editing_save", %{}, socket) do
    {:noreply, socket |> assign(%{
      query: "",
      be_editing: nil,
      be_editing_name: "",
      be_list: Bootenv.list,
      })}
  end
end
