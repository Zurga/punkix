defmodule Punkix.Components.ListComponent do
  @moduledoc """
  A generic component that will display the data given in a list. Several actions are supported for the data type in the list.

  These are:
  - sorting the items,
  - adding a new item at a given location in the list,
  - removing an item,
  - duplicating an item.

  The component that goes into the default slot will have the responsibility to handle these actions. The results of these actions can be broadcast back to the ListComponents in the application by using the `handle_[action]` functions that are provided by this module.

  The assigns in the LiveView are automatically updated by using the `values` prop option in Surface. Setting this to the module name of the items in the list is enough for the ListComponent to be able to handle all the actions.

  ### Using a ListComponent
  It is important to attach all the relevant hooks to the LiveView that will incorporate the ListComponent.

  This can be done with the `attach_hooks/3` function as follows:
  ```
  def mount(_, _, socket) do
    {:ok, ListComponents.attach_hooks(socket, __MODULE__)}
  end
  ```
  """
  # TODO
  # handle_new
  # handle_duplicate
  use Surface.LiveComponent
  import Punkix.Components.Utils

  prop(data, :generator)
  prop(item_id_prefix, :string)
  prop(sortable, :boolean)
  data(item_ids, :list)
  slot(default, generator_prop: :data, arg: %{id: :string}, required: true)

  def update(assigns, socket) do
    data_struct =
      assigns.data
      |> Enum.at(0)
      |> case do
        %{__struct__: struct} ->
          struct
          |> Module.split()
          |> List.last()

        nil ->
          nil
      end

    socket =
      assign(socket, assigns)
      |> assign(data_struct: data_struct)

    {:ok, socket}
  end

  def render(assigns) do
    assigns =
      assign(assigns, :item_ids, Enum.map(assigns[:data], &item_id(&1, assigns[:item_id_prefix])))

    ~F"""
    <div
      id={"#{@id}-wrapper"}
      :hook
      data-assign="data"
      data-target={@myself}
    >
      {#for {{item_id, item}, index} <- Enum.zip(@item_ids, @data) |> Enum.with_index()}
        <button :if={index == 0} phx-click={"new", target: "##{item_id}"} value="before">New</button>
        <#slot {@default, id: item_id} generator_value={item} />
        <button phx-click={"new", target: "##{item_id}"} value="after">New</button>
      {/for}
    </div>
    """
  end

  @impl true
  def handle_event(
        "sort-data",
        %{"to" => to, "from" => from},
        %{assigns: %{data: data}} = socket
      ) do
    data = swap(data, from, to)
    send(self(), {:sort, data})

    {:noreply, assign(socket, data: data)}
  end

  def replace_by_id(elements, element) do
    index = Enum.find_index(elements, &(&1.id == element.id))
    List.replace_at(elements, index, element)
  end

  def find_assign(view, socket, %{__struct__: schema}) do
    find_assign(view, socket, schema)
  end

  def find_assign(view, _socket, module) when is_atom(module) do
    Enum.filter(view.__data__(), fn
      %{opts: [values: [^module]]} -> true
      _ -> false
    end)
  end

  #  @callback create(struct :: struct(), params :: map(), socket :: Socket.t()) ::
  #              {:ok, socket :: Socket.t()}
  #              | {:error, socket :: Socket.t()}
  #
  #  @callback update(struct :: struct(), params :: map(), socket :: Socket.t()) ::
  #              {:ok, socket :: Socket.t()}
  #              | {:error, socket :: Socket.t()}
  #
  #  @callback delete(struct :: struct(), socket :: Socket.t()) ::
  #              {:ok, socket :: Socket.t()}
  #              | {:error, socket :: Socket.t()}
  #
  #  @callback sort(structs :: [struct()], socket :: Socket.t()) ::
  #              {:ok, Socket.t()} | {:error, Socket.t()}
  @doc """
  Will set up the necessary hooks to handle the different actions that can be triggered.
  """
  def attach_hooks(socket, view, opts \\ %{}) do
    IO.inspect(view)

    attach_hook(socket, :handle_update, :handle_info, fn event, socket ->
      do_handle_info(event, socket, view, opts)
    end)
  end

  defp do_handle_info({:create, module, params}, socket, view, opts) do
    socket =
      case apply_view_func(:create, module, params, opts, view, socket) do
        {:ok, value, socket} ->
          send(self(), {:after_create, value})
          socket
      end

    {:halt, socket}
  end

  defp do_handle_info({:after_create, value}, socket, view, _opts) do
    socket = every_assign(view, socket, value, &insert_by_index/2)
    {:halt, socket}
  end

  defp do_handle_info({:update, struct}, socket, view, _opts) do
    {:cont, every_assign(view, socket, struct, &replace_by_id/2)}
  end

  defp do_handle_info({:after_update, struct}, socket, view, _opts) do
    {:cont, every_assign(view, socket, struct, &replace_by_id/2)}
  end

  defp do_handle_info({:delete, struct}, socket, view, opts) do
    socket =
      case apply_view_func(:delete, struct, opts, view, socket) do
        {:ok, socket} -> socket
      end

    send(self(), {:after_delete, struct})

    {:halt, socket}
  end

  defp do_handle_info({:after_delete, struct}, socket, view, _opts) do
    {:halt,
     every_assign(view, socket, struct, fn elements, element ->
       Enum.reject(elements, &(&1.id == element.id))
     end)}
  end

  defp do_handle_info({:sort, structs}, socket, view, opts) do
    socket =
      case apply_view_func(:sort, structs, opts, view, socket) do
        {:ok, _socket} ->
          send(self(), {:after_sort, structs})
      end

    {:halt, socket}
  end

  defp do_handle_info({:after_sort, structs}, socket, view, _opts) do
    socket = every_assign(view, socket, structs, fn _, new_elements -> new_elements end)
    {:halt, socket}
  end

  defp every_assign(view, socket, [struct | _] = structs, fun) when is_list(structs) do
    every_assign(view, socket, struct, fn old_elements, _ ->
      fun.(old_elements, structs)
    end)
  end

  defp every_assign(view, socket, struct, fun) do
    find_assign(view, socket, struct)
    |> Enum.reduce(socket, fn %{name: assign}, socket ->
      data =
        fun.(socket.assigns[assign], struct)

      assign(socket, assign, data)
    end)
  end

  defp apply_view_func(event, struct, args \\ [], opts, view, socket)
       when is_map(opts) and is_atom(view) do
    args = List.wrap(struct) ++ List.wrap(args) ++ [socket]

    case opts[struct.__struct__][event] do
      fun when is_function(fun) ->
        apply(fun, args)

      _ ->
        try do
          apply(view, event, args)
        rescue
          _error in [FunctionClauseError, UndefinedFunctionError] ->
            {:error, "event not defined #{inspect(event)} #{inspect(opts)}"}
        end
    end
  end

  defp item_id(item, nil) do
    type_name =
      Module.split(item.__struct__)
      |> List.last()
      |> String.downcase()

    type_name <> "-" <> to_string(item.id)
  end

  defp item_id(item, prefix) do
    (prefix <> "-" <> item_id(item, nil))
    |> IO.inspect()
  end
end
