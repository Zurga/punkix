defmodule <%= @web_namespace %>.FormComponent do
  defmacro __using__(_) do
    quote do
      use Surface.LiveComponent
      alias Surface.Components.Form
      alias Surface.Components.Form.{Field}
      import unquote(__MODULE__)

      unquote(<%= @web_namespace %>.html_helpers())
    end
  end

  import Ecto.Changeset

  @validators [
    required: {&validate_required/3, ~w/message/a},
    length: {&validate_length/3, ~w/is min max count message/a},
    in: {&validate_inclusion/4, ~w/message/a},
    format: {&validate_format/4, ~w/message/a},
    acceptance: {&validate_acceptance/3, ~w/message/a},
    exclude: {&validate_exclusion/3, ~w/message/a},
  ]

  def prepare_for_insert(changeset, params, action) do
    apply(changeset.__struct__, :changeset, [changeset, params])
    |> apply_action(action)
  end
   
  def normalize_input(params, input_schema) do
    types = input_schema |> Enum.map(fn {k, [type | _]} -> {k, type} end) |> Enum.into(%{})
    validations = schema_validations(input_schema)
    
    {%{}, types}
    |> cast(params, Keyword.keys(input_schema))
    |> then(&Enum.reduce(validations, &1, fn validation, acc ->
      validation.(acc)
    end))
    # |> apply_action(:validate)
    # |> case do
    #   {:ok, normalized_input} -> normalized_input
    #   error -> error
    # end
  end

    defp schema_validations(schema) do
      Enum.flat_map(schema, fn {k, [_type | field_opts]} ->
        Enum.flat_map(@validators, fn {validator, {fun, validator_opts}} ->
          opts = Keyword.take(field_opts, validator_opts)
          case field_opts[validator] do
            nil -> []
            true -> 
              [fn changeset -> fun.(changeset, k, opts) end]
            data -> 
              args = case Function.info(fun, :arity) do
                {:arity, 2} -> [k]
                {:arity, 3} -> [k, opts]
                {:arity, 4} -> [k, data, opts]
              end
              [fn changeset -> apply(fun, [changeset | args]) end]
          end
        end)
      end)
    end

#   def autosave(%{assigns: %{action: :new}} = socket, params) do
#     changeset = do_change(params, socket)

#     assign(socket, changeset: changeset, saved: false)
#   end

#   def autosave(%{assigns: %{action: action}} = socket, params) do
#     changeset = do_change(params, socket)

#     socket
#     |> assign(changeset: changeset)
#     |> save(socket.assigns.action, params)
#     |> maybe_put_changeset(socket)
#   end

#   defp maybe_put_changeset(result, socket) do
#     case result do
#       {:ok, socket} ->
#         assign(socket, saved: true)

#       {:error, changeset} ->
#         assign(socket, changeset: changeset, saved: false)
#     end
#   end

#   defp do_change(params, socket) do
#     change(params, socket)
#     |> Map.put(:action, :validate)
#   end

#   @impl true
#   def handle_event("unsaved", _, socket),
#     do: {:noreply, assign(socket, saved: false)}
end
