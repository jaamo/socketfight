defmodule SocketfightWeb.Router do
  use SocketfightWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SocketfightWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/muumi", MuumiController, :index
    get "/muumi/:character", MuumiController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", SocketfightWeb do
  #   pipe_through :api
  # end
end
