defmodule SocketfightWeb.PageController do
  use SocketfightWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
