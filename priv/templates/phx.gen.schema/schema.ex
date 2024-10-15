defmodule <%= inspect schema.module %> do
  use <%= Mix.Phoenix.base() %>.Schema
  alias <%= Mix.Phoenix.base() %>.Schemas.{<%= Punkix.Schema.assoc_aliasses(schema) %>}
<%= if schema.prefix do %>
  @schema_prefix :<%= schema.prefix %><% end %><%= if schema.binary_id do %>
  @primary_key {:id, UUIDv7, autogenerate: true}
  @foreign_key_type UUIDv7<% end %>
  typed_schema <%= inspect schema.table %> do
<%= Mix.Phoenix.Schema.format_fields_for_schema(schema) %>
    <%= Punkix.Schema.format_assocs(schema) %>
    timestamps(<%= if schema.timestamp_type != :naive_datetime, do: "type: #{inspect schema.timestamp_type}" %>)
  end
end
