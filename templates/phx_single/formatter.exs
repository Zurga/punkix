[
  import_deps: [<%= if @ecto do %>:ecto, :ecto_sql, <% end %>:phoenix, :surface],<%= if @ecto do %>
  subdirectories: ["priv/*/migrations"],<% end %><%= if @html do %>
  plugins: [Surface.Formatter.Plugin],<% end %>
  inputs: [<%= if @html do %>"*.{heex, sface,ex,exs}", "{config,lib,test}/**/*.{heex, sface, ex,exs}"<% else %>"*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"<% end %><%= if @ecto do %>, "priv/*/seeds.exs"<% end %>]
]
