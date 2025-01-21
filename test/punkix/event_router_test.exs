defmodule Punkix.EventRouterTest do
  use Punkix.RepoCase
  alias Surface.Compiler.ParseTreeTranslator
  alias Punkix.EventRouter

  describe "Basic usage" do
    setup do
      start_supervised!(TestRepo)
      {:ok, test} = TestRepo.insert(%Test{})
      start_supervised!({Phoenix.PubSub, name: Punkix.PubSub})

      start_supervised!(
        {Punkix.EventRouter,
         cache_name: :dbcache,
         repo: TestRepo,
         pub_sub: Punkix.PubSub,
         watchers:
           [{TestCase, :updated, trigger_columns: [:name], label: :name_updated}]
           |> EventRouter.all_events(Test)
           |> EventRouter.all_events(TestCase, extra_columns: [:test_id])}
      )

      [test_value: test, preloads: [:test]]
    end

    test "seperate genserver can subscribe and receive messages", %{test_value: test} do
      subscriber1 = start_link_supervised!(EventSubscriber)
      EventSubscriber.subscribe(subscriber1, {TestCase, :inserted})

      {:ok, %{id: test_case_id} = test_case} = TestRepo.insert(%TestCase{test_id: test.id})

      event = events(subscriber1, %TestCase{})

      assert event[:inserted] == test_case
    end

    test "updates, deletes are sent", %{test_value: test} do
      {:ok, test_case} =
        TestRepo.insert(%TestCase{test_id: test.id})

      EventRouter.subscribe(test_case)

      # receive do
      #   {{TestCase, :inserted}, get_fun} ->
      #     {:ok, cached} = get_fun.()
      #     assert cached == test_case
      # after
      #   1000 ->
      #     raise "nothing"
      # end

      {:ok, updated} =
        Ecto.Changeset.change(test_case, %{name: "updated"})
        |> TestRepo.update()

      receive do
        {{TestCase, :updated}, get_fun} ->
          {:ok, cached} = get_fun.()
          assert cached == updated
      after
        1000 ->
          raise "no updates"
      end

      {:ok, updated} = TestRepo.delete(test_case)

      receive do
        {{TestCase, :deleted}, get_fun} ->
          {:ok, id} = get_fun.()
          assert id == updated.id
      after
        1000 ->
          raise "no deletes"
      end
    end

    test "preloads can be set", %{test_value: test, preloads: preloads} do
      EventRouter.subscribe({TestCase, :inserted}, preloads: preloads)

      {:ok, test_case} =
        TestRepo.insert(%TestCase{test_id: test.id})
        |> TestRepo.maybe_preload(preloads)

      receive do
        {{TestCase, :inserted}, get_fun} ->
          {:ok, cached} = get_fun.()
          assert cached == test_case
      after
        1000 ->
          raise "nothing"
      end
    end

    # test "subscriptions based on assocs work", %{test_value: test} do
    #   EventRouter.subscribe(TestCase, {:test_id, test.id})
    # end

    test "unsubscribe", %{
      test_value: test
    } do
      EventRouter.subscribe({TestCase, :inserted})

      {:ok, test_case} =
        TestRepo.insert(%TestCase{test_id: test.id})

      receive do
        {{TestCase, :inserted}, get_fun} ->
          {:ok, cached} = get_fun.()
          assert cached == test_case
      after
        1000 ->
          raise "nothing"
      end

      EventRouter.unsubscribe(%TestCase{})
    end

    test "preloads are distributed differently among subscribers", %{
      test_value: test,
      preloads: preloads
    } do
      {:ok, subscriber1} = start_supervised({EventSubscriber, name: "preloads"})
      EventSubscriber.subscribe(subscriber1, {TestCase, :inserted})
      EventRouter.subscribe({TestCase, :inserted}, preloads: preloads)

      {:ok, test_case} = TestRepo.insert(%TestCase{test_id: test.id})

      subscriber1_inserted = events(subscriber1, %TestCase{})[:inserted]

      inserted =
        receive do
          {{TestCase, :inserted}, get_fun} ->
            {:ok, inserted} = get_fun.()

            inserted
        after
          1000 ->
            raise "nothing"
        end

      refute subscriber1_inserted == inserted
    end
  end

  def events(pid, schema) do
    Process.sleep(100)
    EventSubscriber.events(pid, schema)
  end
end
