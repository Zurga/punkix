[
  import_deps: [<%= if @ecto do %>:ecto, :ecto_sql, <% end %>:phoenix, :surface],<%= if @ecto do %>
  subdirectories: ["priv/*/migrations"],<% end %><%= if @html do %>
  plugins: [Surface.Formatter.Plugin],<% end %>
  inputs: [
    "*.{heex, sface,ex,exs}", 
    "{config,lib,test}/**/*.{heex, sface, ex,exs}",
    "*.{ex,exs}", 
    "{config,lib,test}/**/*.{ex,exs}", 
    "priv/*/seeds.exs"
  ]
]
