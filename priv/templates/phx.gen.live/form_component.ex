defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.FormComponent do
  use <%= inspect context.web_module %>.FormComponent

  alias <%= inspect context.module %>
  <%= Mix.Tasks.Punkix.Gen.Live.input_aliases(schema) %>

  defmodule <%= inspect(schema.alias) %>.Form do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      <%= for {key, type} <- schema.attrs, type != :map and is_atom(type) == true do %>
      field <%= inspect(key) %>, <%= inspect(type) %><% end %>
    end

    def changeset(<%= schema.singular %>_or_changeset, attrs \\ %{}) do
      <%= schema.singular %>_or_changeset
      |> cast(attrs, [<%= Enum.map_join(schema.attrs, ", ", &inspect(elem(&1, 0))) %>])
      |> validate_required([<%= Enum.map_join(Mix.Phoenix.Schema.required_fields(schema), ", ", &inspect(elem(&1, 0))) %>])
    end

    def change(struct, attrs, action) do
      {:ok, changeset(struct, attrs)
      |> apply_action!(action)
      |> Map.take([<%= Enum.map_join(schema.attrs, ", ", &inspect(elem(&1, 0))) %>])}
    end
  end

  prop title, :string
  prop <%= schema.singular %>, :any
  prop action, :atom, default: :new
  prop patch, :string
  data changeset, :changeset

  @impl true
  def render(assigns) do
    ~F"""
    <div>
      <header>
        {@title}
        <p>Use this form to manage <%= schema.singular %> records in your database.</p>
      </header>

      <Form
        for={@changeset}
        id={"<%= schema.singular %>-form"}
        change="validate"
        submit="save"
        opts={"phx-target": @myself}
      >
<%= Mix.Tasks.Phx.Gen.Html.indent_inputs(inputs, 8) %>
        <button phx-disable-with="Saving...">Save <%= schema.human_singular %></button>
      </Form>
    </div>
    """
  end

  @impl true
  def update(%{<%= schema.singular %>: <%= schema.singular %>} = assigns, socket) do
    changeset = <%= inspect schema.alias %>.Form.changeset(<%= schema.singular %>)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    changeset = <%= inspect schema.alias %>.Form.changeset(~a[<%= schema.singular %>], <%= schema.singular %>_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    {:noreply, save_<%= schema.singular %>(socket, ~a[action], <%= schema.singular %>_params)}
  end

  defp save_<%= schema.singular %>(socket, :edit, <%= schema.singular %>_params) do
    with {:ok, <%= schema.singular %>_params} <- <%= inspect schema.alias %>.Form.change(~a[<%= schema.singular %>], <%= schema.singular %>_params, ~a[action]), 
      {:ok, <%= schema.singular %>} <-
          <%= context.name %>.update_<%= schema.singular %>(~a[<%= schema.singular %>].id, <%= schema.singular %>_params) do
        notify_parent({:saved, <%= schema.singular %>})

         socket
         |> put_flash(:info, "<%= schema.human_singular %> updated successfully")
         |> push_patch(to: ~a[patch])
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        assign_form(socket, changeset)
    end
  end

  defp save_<%= schema.singular %>(socket, :new, <%= schema.singular %>_params) do
    with {:ok, <%= schema.singular %>_params} <- <%= inspect schema.alias %>.Form.change(~a[<%= schema.singular %>], <%= schema.singular %>_params, ~a[action]), 
      {:ok, <%= schema.singular %>} <-
          <%= context.name %>.create_<%= schema.singular %>(<%= schema.singular %>_params) do
        notify_parent({:saved, <%= schema.singular %>})

         socket
         |> put_flash(:info, "<%= schema.human_singular %> created successfully")
         |> push_patch(to: ~a[patch])
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        assign_form(socket, changeset)
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :changeset, changeset)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
