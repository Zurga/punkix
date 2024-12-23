<%= Punkix.Context.assoc_fixtures(context.schema) %>
<%= for {attr, {_function_name, function_def, _needs_impl?}} <- schema.fixture_unique_functions do %>  @doc """
  Generate a unique <%= schema.singular %> <%= attr %>.
  """
<%= function_def %>
<% end %>  @doc """
  Generate a <%= schema.singular %>.
  """
  def <%= schema.singular %>_fixture(attrs \\ %{}) do
    <%= schema.singular %>_attrs = 
      <%= Punkix.Context.args_to_params(schema, :create) %> 
      |> Map.merge(attrs)<%= for assoc <- Punkix.Context.required_assocs(context.schema) do %>
      |> Map.put_new_lazy(:<%= assoc.field %>, &<%= String.downcase(assoc.schema) %>_fixture/0)<% end %>
    {:ok, <%= schema.singular %>} = <%= inspect context.module %>.create_<%= schema.singular %>(<%= schema.singular %>_attrs)

    <%= schema.singular %>
  end
