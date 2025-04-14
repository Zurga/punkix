defmodule <%= @web_namespace %> do
  @moduledoc """
  Contains the helper functions that will be used in other modules that define the different parts of the web subsystem.
  """
  use Boundary, deps: [<%= @app_module %>], exports: [<%= @web_namespace %>.Endpoint]

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      <%= if @gettext do %>import <%= @web_namespace %>.Gettext<% end %>
      import Punkix.Web, only: [sigil_a: 2, on_create: 1, on_create: 2, on_update: 1, on_update: 2, maybe_patch_and_flash: 4]

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: <%= @endpoint_module %>,
        router: <%= @web_namespace %>.Router,
        statics: <%= @web_namespace %>.static_paths()
    end
  end
end
