defmodule Tuesday.Router do
  use Tuesday.Web, :router

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

  scope "/", Tuesday do
    pipe_through :browser # Use the default browser stack

    # get "/", PageController, :index
    # resources "/episodes", EpisodeController, except: [:new, :edit]
  end

  # Other scopes may use custom stacks.
  scope "/api", Tuesday do
    pipe_through :api

    post "/poke", AdminController, :poke
  end
end
