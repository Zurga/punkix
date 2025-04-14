  <%= Punkix.Context.assoc_fixtures(schema) %>
  <%= Punkix.Context.assocs_schema_aliasses(schema) %>
  @create_attrs <%= Punkix.Context.args_to_params(schema, :create) %>
  @update_attrs <%= Punkix.Context.args_to_params(schema, :update) %>
  @invalid_attrs %{<%= Punkix.Context.invalid_args_to_params(schema, :update) %>}

  describe "<%= schema.plural %>" do
    alias <%= inspect schema.module %>

    import <%= inspect context.module %>Fixtures

    test "list_<%= schema.plural %>/0 returns all <%= schema.plural %>" do
      <%= schema.singular %> = <%= schema.singular %>_fixture()
      auto_assert [%<%= inspect(schema.alias) %>{}] <- <%= inspect context.alias %>.list_<%= schema.plural %>() 
    end

    test "get_<%= schema.singular %>/1 returns the <%= schema.singular %> with given id" do
      <%= schema.singular %> = <%= schema.singular %>_fixture()
      auto_assert {:ok, %<%= inspect schema.alias %>{}} <- <%= inspect context.alias %>.get_<%= schema.singular %>(<%= schema.singular %>.id) 
    end

    test "create_<%= schema.singular %>/1 with valid data creates a <%= schema.singular %>" do
      create_attrs = 
        @create_attrs<%= for assoc <- Punkix.Context.required_assocs(schema) do %>
        |> Map.put(:<%= assoc.field %>, <%= String.downcase(assoc.schema) %>_fixture()) <% end %>
      auto_assert {:ok, %<%= inspect schema.alias %>{
      <%= for {field, value} <- schema.params.create do %>
        <%= field %>: <%= Mix.Phoenix.Schema.value(schema, field, value) %>,
      <% end %> }} <- <%= inspect context.alias %>.create_<%= schema.singular %>(create_attrs)
    end

    test "create_<%= schema.singular %>/1 with invalid data returns error changeset" do
      invalid_attrs = 
        @invalid_attrs<%= for assoc <- Punkix.Context.required_assocs(schema) do %>
        |> Map.put(:<%= assoc.field %>, <%= String.downcase(assoc.schema) %>_fixture()) <% end %>
      auto_assert {:error, %Ecto.Changeset{}} <- <%= inspect context.alias %>.create_<%= schema.singular %>(invalid_attrs)
    end

    @mneme default_pattern: :last, force_update: true, action: :accept
    test "update_<%= schema.singular %>/2 with valid data updates the <%= schema.singular %>" do
      <%= schema.singular %> = <%= schema.singular %>_fixture()

      auto_assert {:ok, %<%= inspect(schema.alias) %>{
      <%= for {field, value} <- schema.params.update do %>
      <%= field %>: <%= Mix.Phoenix.Schema.value(schema, field, value) %>,<% end %>
      <%= for assoc <- Punkix.Context.required_assocs(schema) do %>
      <%= assoc.field %>: %<%= assoc.schema %>{},<% end %>
      }}  = <%= inspect context.alias %>.update_<%= schema.singular %>(<%= schema.singular %>.id, @update_attrs)
    end

    test "update_<%= schema.singular %>/2 with invalid data returns error changeset" do
      <%= schema.singular %> = <%= schema.singular %>_fixture()
      auto_assert {:error, %Ecto.Changeset{}} <- <%= inspect context.alias %>.update_<%= schema.singular %>(<%= schema.singular %>.id, @invalid_attrs)
    end

    test "delete_<%= schema.singular %>/1 deletes the <%= schema.singular %>" do
      <%= schema.singular %> = <%= schema.singular %>_fixture()
      auto_assert {:ok, %<%= inspect schema.alias %>{}} <- <%= inspect context.alias %>.delete_<%= schema.singular %>(<%= schema.singular %>.id)
      auto_assert {:error, :not_found} <- <%= inspect context.alias %>.get_<%= schema.singular %>(<%= schema.singular %>.id)
    end
  end
