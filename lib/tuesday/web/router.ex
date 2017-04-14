defmodule Tuesday.Web.Router do
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

  scope "/", Tuesday.Web do
    pipe_through :browser

    get "/", PageController, :index
    # resources "/episodes", EpisodeController, except: [:new, :edit]
  end

  scope "/api", Tuesday.Web do
    pipe_through :api

    get "/myip", AjaxController, :myip

    post "/poke", AdminController, :poke
  end
end
