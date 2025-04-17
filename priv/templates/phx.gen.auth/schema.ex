defmodule <%= inspect schema.module %> do
  use <%= Mix.Phoenix.base() %>.Schema<%= if schema.assocs != [] do %>
  alias <%= Mix.Phoenix.base() %>.Schemas.{<%= Punkix.Schema.assoc_aliasses(schema) %>}<% end %>

<%= if schema.binary_id do %>  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id<% end %>
  typed_schema <%= inspect schema.table %> do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime

    <%= Punkix.Schema.format_assocs(schema) %>
    timestamps(<%= if schema.timestamp_type != :naive_datetime, do: "type: #{inspect schema.timestamp_type}" %>)
  end
end
