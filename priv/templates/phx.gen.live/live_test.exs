defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>LiveTest do
  use <%= inspect context.web_module %>.LiveCase
  use Wallaby.Feature, sandbox: false

  import <%= inspect context.module %>Fixtures
  <%= Punkix.Context.assoc_fixtures(context.schema) %>

  @create_attrs %{<%= for {function, field, value} <- schema.params.create
    |> Map.to_list()
    |> Enum.concat(Punkix.Schema.belongs_assocs(schema))
    |> Enum.map(fn 
    {key, value} -> 
      {:fillable_field, "#{schema.singular}-form_#{key}", Mix.Phoenix.Schema.live_form_value(value)}
    %{field: field, plural: plural, schema: assoc_schema} ->
      {:select, "#{schema.singular}-form_#{field}_id", "#{assoc_schema} 1"}
    end) do %>
      <%= function %>("<%= field %>") => "<%= value %>",
    <% end %>}
  @update_attrs %{<%= for {function, field, value} <- 
    schema.params.update
    |> Map.to_list()
    |> Enum.map(fn  {key, value} -> 
      {:fillable_field, "#{schema.singular}-form_#{key}", Mix.Phoenix.Schema.live_form_value(value)}
    end) do %>
      <%= function %>("<%= field %>") => "<%= value %>",
    <% end %>}
  @invalid_attrs <%= Mix.Phoenix.to_text for {key, value} <- schema.params.create, into: %{}, do: {key, value |> Mix.Phoenix.Schema.live_form_value() |> Mix.Phoenix.Schema.invalid_form_value()} %>

  defp create_<%= schema.singular %>(_) do
    <%= schema.singular %> = <%= schema.singular %>_fixture()
    %{<%= schema.singular %>: <%= schema.singular %>}
  end

  defp cleanup(_) do
    <%= for assoc <- Punkix.Context.required_assocs(context.schema) do %>
      <%= context.base_module %>.Repo.delete_all(<%= inspect context.base_module %>.Schemas.<%= assoc.alias %>)
    <% end %>
    <%= inspect context.base_module %>.Repo.delete_all(<%= inspect schema.module %>)

    :ok
  end

  describe "Index" do
    setup [:cleanup, :create_<%= schema.singular %>]

    feature "lists all <%= schema.plural %>", <%= if schema.string_attr do %>%{session: session, <%= schema.singular %>: <%= schema.singular %>}<% else %>%{session: session}<% end %> do
      session
      |> visit(~p"<%= schema.route_prefix %>")
      |> assert_text("Listing <%= schema.human_plural %>")<%= if schema.string_attr do %>
      |> assert_text(<%= schema.singular %>.<%= schema.string_attr %>)<% end %>
    end

    feature "saves new <%= schema.singular %>", %{session: session} do
      session
      |> visit(~p"<%= schema.route_prefix %>")
      |> click(css("a", text: "New <%= schema.human_singular %>"))
      |> assert_text("New <%= schema.human_singular %>")
      |> fill_form(@create_attrs)
      # |> change_form("#<%= schema.singular %>-form", <%= schema.singular %>_form: @invalid_attrs)
      # |> assert_text("<%= Mix.Phoenix.Schema.failed_render_change_message(schema) %>")
      # |> submit_form("#<%= schema.singular %>-form", <%= schema.singular %>_form: @create_attrs)
      |> click(button("Save <%= schema.human_singular %>"))
      |> assert_text("<%= schema.human_singular %> created successfully")<%= if schema.string_attr do %>
      |> assert_text("some <%= schema.string_attr %>")<% end %>
    end

    feature "updates <%= schema.singular %> in listing", %{session: session, <%= schema.singular %>: <%= schema.singular %>} do
      session
      |> visit(~p"<%= schema.route_prefix %>")
      |> click(css(~s{a[href="/<%= schema.plural %>/#{<%= schema.singular %>.id}/edit"]}))
      |> assert_text("Edit <%= schema.human_singular %>")
      # |> change_form("#<%= schema.singular %>-form", <%= schema.singular %>_form: @invalid_attrs)
      # |> assert_text("<%= Mix.Phoenix.Schema.failed_render_change_message(schema) %>")
      |> fill_form(@update_attrs)
      |> click(button("Save <%= schema.human_singular %>"))
      # |> submit_form("#<%= schema.singular %>-form", <%= schema.singular %>_form: @update_attrs)
      |> assert_text("<%= schema.human_singular %> updated successfully")<%= if schema.string_attr do %>
      |> assert_text("some updated <%= schema.string_attr %>")<% end %>
    end

    feature "deletes <%= schema.singular %> in listing", %{session: session, <%= schema.singular %>: <%= schema.singular %>} do
      session
      |> visit(~p"<%= schema.route_prefix %>")
      assert "Are you sure?" == accept_alert(session, fn (s) ->
        click(s, css("#<%= schema.plural %>-#{<%= schema.singular %>.id} a", text: "Delete"))
      end)
      refute_has(session, css("#<%= schema.plural %>-#{<%= schema.singular %>.id}"))
    end
  end

  describe "Session interactions" do
    setup :cleanup

    @sessions 2
    feature "Inserts, updates and deletes are distributed to other sessions", %{sessions: sessions} do
      <%= for assoc <- Punkix.Context.required_assocs(context.schema) do %>
      <%= String.downcase(assoc.schema) %>_fixture()
      <% end %>
      [session1, session2] = Enum.map(sessions, &visit(&1, ~p"<%= schema.route_prefix %>"))

      session1
      |> click(css("a", text: "New <%= schema.human_singular %>"))
      |> fill_form(@create_attrs)
      |> click(button("Save <%= schema.human_singular %>"))

      session2<%= if schema.string_attr do %>
      |> assert_text("some <%= schema.string_attr %>")
      |> click(css("a", text: "Edit"))
      |> fill_form(@update_attrs)
      |> click(button("Save <%= schema.human_singular %>"))
      |> assert_text("<%= schema.human_singular %> updated successfully")

      session1
      |> assert_text("some updated <%= schema.string_attr %>")<% end %>
    end
  end

  describe "Show" do
    setup [:cleanup, :create_<%= schema.singular %>]

    feature "displays <%= schema.singular %>", %{session: session, <%= schema.singular %>: <%= schema.singular %>} do
      session
      |> visit(~p"<%= schema.route_prefix %>/#{<%= schema.singular %>}")<%= if schema.string_attr do %>
      |> assert_text(<%= schema.singular %>.<%= schema.string_attr %>)<% end %>
    end

    feature "updates <%= schema.singular %> within modal", %{session: session, <%= schema.singular %>: <%= schema.singular %>} do
      session
      |> visit(~p"<%= schema.route_prefix %>/#{<%= schema.singular %>}")
      |> click(css("a", text: "Edit"))
      |> assert_text("Edit <%= schema.human_singular %>")
      |> fill_form(@update_attrs)
      # |> change_form("#<%= schema.singular %>-form", <%= schema.singular %>_form: @invalid_attrs)
      # |> assert_text("<%= Mix.Phoenix.Schema.failed_render_change_message(schema) %>")
      # |> submit_form("#<%= schema.singular %>-form", <%= schema.singular %>_form: @update_attrs)
      |> click(button("Save <%= schema.human_singular %>"))
      |> assert_text("<%= schema.human_singular %> updated successfully")<%= if schema.string_attr do %>
      |> assert_text("some updated <%= schema.string_attr %>")<% end %>
    end
  end
end
