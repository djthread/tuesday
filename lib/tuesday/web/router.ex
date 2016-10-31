defmodule Tuesday.Web.Router do
  use Tuesday.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated,
      handler: Tuesday.Web.AdminController
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/", Tuesday.Web do
    pipe_through :browser

    get "/", PageController, :index
    # resources "/episodes", EpisodeController, except: [:new, :edit]
  end

  scope "/api", Tuesday.Web do
    pipe_through :api

    get "/myip", AjaxController, :myip

    post "/poke", PokeController, :poke

    post "/auth", AdminController, :auth
  end

  scope "/api", Tuesday do
    pipe_through [:api, :auth]

    get "/whoami", AdminController, :whoami
    get "/show/:id", AdminController, :show
  end
end
