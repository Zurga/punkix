<%= for {attr, {_function_name, function_def, _needs_impl?}} <- schema.fixture_unique_functions do %>  @doc """
  Generate a unique <%= schema.singular %> <%= attr %>.
  """
<%= function_def %>
<% end %>  @doc """
  Generate a <%= schema.singular %>.
  """
  def <%= schema.singular %>_fixture(_attrs \\ %{}) do
    {:ok, <%= schema.singular %>} = <%= inspect context.module %>.create_<%= schema.singular %>(<%= Punkix.Context.args_to_params(schema, :create) %>)

    <%= schema.singular %>
  end
