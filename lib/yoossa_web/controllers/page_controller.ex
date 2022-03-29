defmodule YoossaWeb.PageController do
  use YoossaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
