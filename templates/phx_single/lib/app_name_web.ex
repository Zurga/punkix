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
      <%= if @gettext do %>use Gettext, backend: <%= @web_namespace %>.Gettext<% end %>
      import Punkix.Web, only: [sigil_a: 2, on_create: 1, on_update: 1, maybe_patch_and_flash: 3, resolve_by_id: 4, put_form_embed: 4, assoc_select: 1]

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
      unquote(routex_helpers())
    end
  end

  defp routex_helpers do
    quote do
      import Phoenix.VerifiedRoutes,
        except: [sigil_p: 2, url: 1, url: 2, url: 3, path: 2, path: 3]

      import unquote(__MODULE__).Router.RoutexHelpers, only: :macros
      alias unquote(__MODULE__).Router.RoutexHelpers, as: Routes
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
