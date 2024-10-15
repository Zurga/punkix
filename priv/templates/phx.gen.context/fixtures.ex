<%= Punkix.Context.assoc_fixtures(context.schema) %>
<%= for {attr, {_function_name, function_def, _needs_impl?}} <- schema.fixture_unique_functions do %>  @doc """
  Generate a unique <%= schema.singular %> <%= attr %>.
  """
<%= function_def %>
<% end %>  @doc """
  Generate a <%= schema.singular %>.
  """
  def <%= schema.singular %>_fixture(attrs \\ %{}) do
<%= for assoc <- Punkix.Context.required_assocs(context.schema) do %>    {<%= assoc.field %>_attrs, attrs} = Map.pop(attrs, :<%= assoc.field %>, %{})
    <%= assoc.field %> = <%= String.downcase(assoc.schema) %>_fixture(<%= assoc.field %>_attrs)<% end %>
    <%= schema.singular %>_attrs = 
      <%= Punkix.Context.args_to_params(schema, :create) %> 
      |> Map.merge(attrs)
    {:ok, <%= schema.singular %>} = <%= inspect context.module %>.create_<%= schema.singular %>(<%= Punkix.Context.context_fun_args(Punkix.Context.required_assocs_as_arguments(schema), schema) %>)

    <%= schema.singular %>
  end
