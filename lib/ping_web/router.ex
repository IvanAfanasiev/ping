defmodule PingWeb.Router do
  use PingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PingWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  pipeline :auth do
    plug Ping.Auth.Pipeline
  end




  scope "/api", PingWeb do
    pipe_through :api

    post "/user/register", UserController, :register
  end
  scope "/api", PingWeb do
    pipe_through [:api, :auth]


    get "/me", UserController, :index
    get "/user/list", UserController, :list
    get "/user/search", UserController, :search_users
    get "/user/:public_id", UserController, :findOne

    patch "/user/update_onesignal_id", UserController, :update_onesignal_id

    put "/user/update", UserController, :update
  end

  scope "/auth", PingWeb do
    pipe_through :api


    post "/login", SessionController, :login
    post "/refresh", SessionController, :refresh_token
    post "/logout", SessionController, :logout
  end

  scope "/api", PingWeb do
    pipe_through [:api, :auth]

    get "/ping/recent", PingController, :list_recent_pings
    get "/ping/list", PingController, :list
    post "/ping", PingController, :create
    patch "/ping/:id", PingController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", PingWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ping, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PingWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
