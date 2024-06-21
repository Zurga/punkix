defmodule <%= @web_namespace %>.Router do
  use Phoenix.Router, helpers: false

  # Import common connection and controller functions to use in pipelines
  import Plug.Conn
  import Phoenix.Controller
  import Phoenix.LiveView.Router
  import Surface.Catalogue.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {<%= @web_namespace %>.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", <%= @web_namespace %> do
    pipe_through :browser
    live "/", IndexLive, :index
    # TODO add your routes here
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      surface_catalogue "/catalogue"
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", <%= @web_namespace %> do
  #   pipe_through :api
  # end
  <%= if @dashboard || @mailer do %>
  # Enable <%= [@dashboard && "LiveDashboard", @mailer && "Swoosh mailbox preview"] |> Enum.filter(&(&1)) |> Enum.join(" and ") %> in development
  if Application.compile_env(:<%= @web_app_name %>, :dev_routes) do<%= if @dashboard do %>
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router<% end %>

    scope "/dev" do
      pipe_through :browser
<%= if @dashboard do %>
      live_dashboard "/dashboard", metrics: <%= @web_namespace %>.Telemetry<% end %><%= if @mailer do %>
      forward "/mailbox", Plug.Swoosh.MailboxPreview<% end %>
    end
  end<% end %>
end
