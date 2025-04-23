defmodule <%= inspect schema.repo %>.Migrations.Create<%= Macro.camelize(schema.table) %>AuthTables do
  use Ecto.Migration

  def change do<%= if Enum.any?(migration.extensions) do %><%= for extension <- migration.extensions do %>
    <%= extension %><% end %>
<% end %>
    create table(:<%= schema.table %><%= if schema.binary_id do %>, primary_key: false<% end %>) do
<%= if schema.binary_id do %>      add :id, :binary_id, primary_key: true
<% end %>      <%= migration.column_definitions[:email] %>
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime <%= for %{assoc_fun: :belongs_to} = assoc <- schema.assocs do %>
      add <%= inspect(assoc.key) %>, references(<%= inspect(assoc.assoc_table) %>, on_delete: :nothing<%= if schema.binary_id do %>, type: :binary_id<% end %>)<%= if assoc.required do %>, null: false<% end %><% end %>

      timestamps(<%= if schema.timestamp_type != :naive_datetime, do: "type: #{inspect schema.timestamp_type}" %>)
    end

    create unique_index(:<%= schema.table %>, [:email])
<%= for %{assoc_fun: :belongs_to, key: key} <- schema.assocs do %>
    create index(<%= inspect(schema.plural) %>, [<%= inspect(key) %>])<% end %>

    create table(:<%= schema.table %>_tokens<%= if schema.binary_id do %>, primary_key: false<% end %>) do
<%= if schema.binary_id do %>      add :id, :binary_id, primary_key: true
<% end %>      add :<%= schema.singular %>_id, references(:<%= schema.table %>, <%= if schema.binary_id do %>type: :binary_id, <% end %>on_delete: :delete_all), null: false
      <%= migration.column_definitions[:token] %>
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:<%= schema.table %>_tokens, [:<%= schema.singular %>_id])
    create unique_index(:<%= schema.table %>_tokens, [:context, :token])
  end
end
