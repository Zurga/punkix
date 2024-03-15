defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>LiveTest do
  use <%= inspect context.web_module %>.ConnCase

  use Skipper.LiveViewTest
  import <%= inspect context.module %>Fixtures

  @create_attrs <%= Mix.Phoenix.to_text for {key, value} <- schema.params.create, into: %{}, do: {key, Mix.Phoenix.Schema.live_form_value(value)} %>
  @update_attrs <%= Mix.Phoenix.to_text for {key, value} <- schema.params.update, into: %{}, do: {key, Mix.Phoenix.Schema.live_form_value(value)} %>
  @invalid_attrs <%= Mix.Phoenix.to_text for {key, value} <- schema.params.create, into: %{}, do: {key, value |> Mix.Phoenix.Schema.live_form_value() |> Mix.Phoenix.Schema.invalid_form_value()} %>

  defp create_<%= schema.singular %>(_) do
    <%= schema.singular %> = <%= schema.singular %>_fixture()
    %{<%= schema.singular %>: <%= schema.singular %>}
  end

  describe "Index" do
    setup [:create_<%= schema.singular %>]

    test "lists all <%= schema.plural %>", <%= if schema.string_attr do %>%{conn: conn, <%= schema.singular %>: <%= schema.singular %>}<% else %>%{conn: conn}<% end %> do
      start(conn, ~p"<%= schema.route_prefix %>")
      |> assert_visible("Listing <%= schema.human_plural %>"<%= if schema.string_attr do %>)
      |> assert_visible(<%= schema.singular %>.<%= schema.string_attr %><% end %>)
    end

    test "saves new <%= schema.singular %>", %{conn: conn} do
      start(conn, ~p"<%= schema.route_prefix %>")
      |> click("a", "New <%= schema.human_singular %>")
      |> rerender()
      |> assert_visible("New <%= schema.human_singular %>")
      |> change_form("#<%= schema.singular %>-form", <%= schema.singular %>: @invalid_attrs)
      |> assert_visible("<%= Mix.Phoenix.Schema.failed_render_change_message(schema) %>")
      |> submit_form("#<%= schema.singular %>-form", <%= schema.singular %>: @create_attrs)
      |> assert_visible("<%= schema.human_singular %> created successfully")<%= if schema.string_attr do %>
      |> assert_visible("some <%= schema.string_attr %>")<% end %>
    end

    test "updates <%= schema.singular %> in listing", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      start(conn, ~p"<%= schema.route_prefix %>")
      |> click("#<%= schema.plural %>-#{<%= schema.singular %>.id} a", "Edit")
      |> assert_visible("Edit <%= schema.human_singular %>")
      |> change_form("#<%= schema.singular %>-form", <%= schema.singular %>: @invalid_attrs)
      |> assert_visible("<%= Mix.Phoenix.Schema.failed_render_change_message(schema) %>")
      |> submit_form("#<%= schema.singular %>-form", <%= schema.singular %>: @update_attrs)
      |> rerender()
      |> assert_visible("<%= schema.human_singular %> updated successfully")<%= if schema.string_attr do %>
      |> assert_visible("some updated <%= schema.string_attr %>")<% end %>
    end

    test "deletes <%= schema.singular %> in listing", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      start(conn, ~p"<%= schema.route_prefix %>")
      |> click("#<%= schema.plural %>-#{<%= schema.singular %>.id} a", "Delete")
      |> refute_element("#<%= schema.plural %>-#{<%= schema.singular %>.id}")
    end
  end

  describe "Show" do
    setup [:create_<%= schema.singular %>]

    test "displays <%= schema.singular %>", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      start(conn, ~p"<%= schema.route_prefix %>/#{<%= schema.singular %>}")
      |> assert_visible("Show <%= schema.human_singular %>")<%= if schema.string_attr do %>
      |> assert_visible(<%= schema.singular %>.<%= schema.string_attr %>)<% end %>
    end

    test "updates <%= schema.singular %> within modal", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      start(conn, ~p"<%= schema.route_prefix %>/#{<%= schema.singular %>}")
      |> click("a", "Edit")
      |> assert_visible("Edit <%= schema.human_singular %>")
      |> change_form("#<%= schema.singular %>-form", <%= schema.singular %>: @invalid_attrs)
      |> assert_visible("<%= Mix.Phoenix.Schema.failed_render_change_message(schema) %>")
      |> submit_form("#<%= schema.singular %>-form", <%= schema.singular %>: @update_attrs)
      |> rerender()
      |> assert_visible("<%= schema.human_singular %> updated successfully")<%= if schema.string_attr do %>
      |> assert_visible("some updated <%= schema.string_attr %>")<% end %>
    end
  end
end
