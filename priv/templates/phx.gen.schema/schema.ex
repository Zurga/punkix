defmodule <%= inspect schema.module %> do
  use <%= Mix.Phoenix.base() %>.Schema
<%= if schema.prefix do %>
  @schema_prefix :<%= schema.prefix %><% end %><%= if schema.binary_id do %>
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id<% end %>
  typed_schema <%= inspect schema.table %> do
<%= Mix.Phoenix.Schema.format_fields_for_schema(schema) %>
<%= for {_, k, _, _} <- schema.assocs do %>    field <%= inspect k %>, <%= if schema.binary_id do %>:binary_id<% else %>:id<% end %>
<% end %>
    timestamps(<%= if schema.timestamp_type != :naive_datetime, do: "type: #{inspect schema.timestamp_type}" %>)
  end
end
