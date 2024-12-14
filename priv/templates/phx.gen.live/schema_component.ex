defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.<%= inspect(schema.alias) %>Component do
  use <%= inspect context.web_module %>.LiveComponent
  use <%= inspect context.web_module %>.FormComponent

  alias <%= inspect context.module %>
  <%= Mix.Tasks.Punkix.Gen.Live.input_aliases(schema) %>

  defmodule <%= inspect(schema.alias) %>Form do
    use Ecto.Schema
    import Ecto.Changeset

    @valid_fields ~w/<%= Enum.map_join(schema.attrs, " ", &elem(&1, 0)) %>/a
    @required_fields ~w/<%= Enum.map_join(Mix.Phoenix.Schema.required_fields(schema), " ", &elem(&1, 0)) %>/a
  
    embedded_schema do<%= for {key, type} <- schema.attrs, type != :map and is_atom(type) == true do %>
      field <%= inspect(key) %>, <%= inspect(type) %><% end %>
    end

    def changeset(<%= schema.singular %>, attrs \\ %{}) do
      <%= schema.singular %>
      |> to_form_struct(__MODULE__, @valid_fields)
      |> cast(attrs, @valid_fields)
      |> validate_required(@required_fields)
    end

    def change(struct, attrs, action) do
      with {:ok, <%= schema.singular %>} <- changeset(struct, attrs) |> apply_action(action) do
        {:ok, Map.take(<%= schema.singular %>, @valid_fields)}
      end
    end
  end

  prop title, :string
  prop <%= schema.singular %>, :any
  prop action, :atom, default: :new
  slot buttons
  data presentation, :atom, from_context: {__MODULE__, :presentation}
  
  @impl true
  def render(assigns) do
    ~F"""
    <div>
      {#case @presentation || :form}
        {#match :form}
          <header>
            {@title}
            <p>Use this form to manage <%= schema.singular %> records in your database.</p>
          </header>

          <Form
            for={@changeset}
            id={"<%= schema.singular %>-form"}
            change="validate"
            submit={@action == :new && "create" || "update"}
            opts={"phx-target": @myself}
          >
    <%= Mix.Tasks.Phx.Gen.Html.indent_inputs(inputs, 8) %>
            <button phx-disable-with="Saving...">Save <%= schema.human_singular %></button>
          </Form>
        {#match :list}
          <div class="buttons">
            <#slot {@buttons} />
            <a
              :on-click="delete"
              data-confirm="Are you sure?"
            >
              Delete
            </a>
          </div>
      {/case}
    </div>
    """
  end

  @impl true
  def update(%{<%= schema.singular %>: <%= schema.singular %>} = assigns, socket) do
    changeset = <%= inspect schema.alias %>Form.changeset(<%= schema.singular %>)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"<%= schema.singular %>_form" => <%= schema.singular %>_params}, socket) do
    changeset = <%= inspect schema.alias %>Form.changeset(~a[<%= schema.singular %>], <%= schema.singular %>_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("create", %{"<%= schema.singular %>_form" => <%= schema.singular %>_params}, socket) do
    socket = with {:ok, <%= schema.singular %>_params} <- <%= inspect schema.alias %>Form.change(~a[<%= schema.singular %>], <%= schema.singular %>_params, ~a[action]), 
      {:ok, <%= schema.singular %>} <-
          <%= context.name %>.create_<%= schema.singular %>(<%= schema.singular %>_params) do
        notify_parent({:created, <%= schema.singular %>})

        socket
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        assign_form(socket, changeset)
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("update", %{"<%= schema.singular %>_form" => <%= schema.singular %>_params}, socket) do
    socket = with {:ok, <%= schema.singular %>_params} <- <%= inspect schema.alias %>Form.change(~a[<%= schema.singular %>], <%= schema.singular %>_params, ~a[action]), 
      {:ok, <%= schema.singular %>} <-
          <%= context.name %>.update_<%= schema.singular %>(~a[<%= schema.singular %>].id, <%= schema.singular %>_params) do
        notify_parent({:updated, <%= schema.singular %>})
        socket
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        assign_form(socket, changeset)
    end
    {:noreply, socket}
  end
  @impl true
  def handle_event("delete", _, socket) do
    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.delete_<%= schema.singular %>(~a[<%= schema.singular %>].id)
    notify_parent({:deleted, <%= schema.singular %>})
    {:noreply, socket}
  end 


  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :changeset, changeset)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
