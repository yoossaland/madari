defmodule MadariWeb.PageController do
  use MadariWeb, :controller
  import Phoenix.LiveView.Helpers

  def index(conn, _params) do
    if conn.assigns.current_user do
      redirect(conn, to: "/home")
    else
      render(conn, "index.html")
    end
  end
end
