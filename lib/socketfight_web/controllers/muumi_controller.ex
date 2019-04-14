defmodule SocketfightWeb.MuumiController do
  use SocketfightWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
  
  def show(conn, %{"character" => character}) do
    render(conn, "show.html", character: character)
  end

end
