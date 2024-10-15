defmodule <%= inspect schema.repo %>.Migrations.Create<%= Macro.camelize(schema.table) %> do
  use <%= inspect schema.migration_module %>

  def change do
    create table(:<%= schema.table %><%= if schema.binary_id do %>, primary_key: false<% end %><%= if schema.prefix do %>, prefix: :<%= schema.prefix %><% end %>) do
<%= if schema.binary_id do %>      add :id, :binary_id, primary_key: true
<% end %><%= for {k, v} <- schema.attrs do %>      add <%= inspect k %>, <%= inspect Mix.Phoenix.Schema.type_for_migration(v) %><%= schema.migration_defaults[k] %>
<% end %><%= for %{assoc_fun: :belongs_to} = assoc <- schema.assocs do %>      add <%= inspect(assoc.key) %>, references(<%= inspect(assoc.assoc_table) %>, on_delete: :nothing<%= if schema.binary_id do %>, type: :binary_id<% end %>)
<% end %>
      timestamps(<%= if schema.timestamp_type != :naive_datetime, do: "type: #{inspect schema.timestamp_type}" %>)
    end
<%= for %{assoc_fun: :belongs_to, key: key} <- schema.assocs do %>      create index(<%= inspect(schema.plural) %>, [<%= inspect(key) %>])<% end %>
  end
end
