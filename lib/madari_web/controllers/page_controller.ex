defmodule MadariWeb.PageController do
  use MadariWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
