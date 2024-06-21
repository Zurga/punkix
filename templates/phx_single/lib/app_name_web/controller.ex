defmodule <%= @web_namespace %>.Controller do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: <%= @web_namespace %>.Layouts]

      import Plug.Conn<%= if @gettext do %>
      import <%= @web_namespace %>.Gettext<% end %>

      unquote(<%= @web_namespace %>.verified_routes())
    end
  end
end
