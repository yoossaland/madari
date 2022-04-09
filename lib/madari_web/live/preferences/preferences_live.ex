defmodule MadariWeb.PreferencesLive do
  use Phoenix.LiveView
  alias Phoenix.LiveView.JS
  alias Madari.Api.Preference
  alias MadariWeb.Router.Helpers, as: Routes
  import Madari.Bulma

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(%{
      default_be: Preference.get("default_be"),
      prefs: Preference.all(),
      # descs: Preference.descriptions_map(),
    })}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
