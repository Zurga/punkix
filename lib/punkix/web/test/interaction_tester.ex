defmodule Punkix.Web.Test.InteractionTester do
  def generate_test(name, interactions) do
    """
    defmodule StockerWeb.InteractionTest.#{name} do
      use StockerWeb.ConnCase, async: true
      import Phoenix.LiveViewTest

      describe "Test" do
        setup [:register_and_log_in_user]
        test "replaying interactions from #{name}", %{conn: conn} do
          {:ok, view, _html} = live(conn, "#{Enum.find(interactions, &(&1["type"] == "path"))["path"]}")

          #{handle_interactions(interactions)}
        end
      end
    end
    """
  end

  def handle_interactions(interactions) do
    Enum.map(interactions, fn
      %{"selector" => selector, "type" => type} = interaction ->
        case type do
          "click" ->
            "view |> element(\"#{interaction["selector"]}\") |> render_click()\n"

          "input" ->
            "view |> element(\"#{interaction["selector"]}\") |> render_change(%{\"value\" => \"#{interaction["value"]}\"})\n"

          "assert_text" ->
            "assert view |> render() =~ \"#{interaction["text"]}\"\n"

          _ ->
            ""
        end

      _ ->
        ""
    end)
    |> Enum.join()
    |> IO.inspect()
  end
end
