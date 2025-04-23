defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.<%= inspect(schema.alias) %>Component do
  use <%= inspect context.web_module %>.LiveComponent
  use <%= inspect context.web_module %>.FormComponent
  use <%= inspect context.web_module %>.Components.Table

  alias <%= inspect context.module %>
  <%= Mix.Tasks.Punkix.Gen.Live.input_aliases(schema) %>

  defmodule <%= inspect(schema.alias) %>Form do
    use Ecto.Schema
    import Ecto.Changeset

    @optional ~w/<%= Enum.join(Punkix.Schema.optional_fields(schema), " ") %>/a
    @required ~w/<%= Enum.join(Punkix.Schema.required_fields(schema), " ") %>/a
    @all @optional ++ @required
  
    embedded_schema do<%= for {key, type} <- schema.attrs, type != :map and is_atom(type) == true do %>
      field <%= inspect(key) %>, <%= inspect(type) %><% end %><%= for assoc <- Punkix.Schema.belongs_assocs(schema) do %>
      field <%= inspect(assoc.key) %>, :integer<% end %>
    end

    def changeset(<%= schema.singular %>, attrs \\ %{}) do
      <%= schema.singular %>
      |> to_form_struct(__MODULE__, @all)
      |> cast(attrs, @all)
      |> validate_required(@required)
    end

    def change(struct, attrs, action) do
      with {:ok, <%= schema.singular %>} <- changeset(struct, attrs) |> apply_action(action) do
        {:ok, Map.take(<%= schema.singular %>, @all)}
      end
    end
  end

  prop title, :string
  prop on_create, :fun, default: &on_create/1
  prop on_update, :fun, default: &on_update/1
  prop <%= schema.singular %>, :any<%= for assoc <- Punkix.Schema.belongs_assocs(schema) do %>
  prop <%= assoc.plural %>, :any
  <% end %>
  prop action, :atom, default: :new

  slot default
  slot buttons

  data presentation, :atom, from_context: {<%= inspect context.web_module %>, :presentation}
  data columns, :list, from_context: {Table, :columns}

  @impl true
  def render(%{presentation: :list} = assigns) do
    ~F"""
    <div {=@id}>
      {#if slot_assigned?(@default)}
        <#slot {@default} />
      {#else}
        <dl><%= for {k, _} <- schema.attrs do %>
          <dt><%= Phoenix.Naming.humanize(Atom.to_string(k)) %></dt>
          <dd>@<%= schema.singular %>.<%= k %></dd><% end %>
        </dl>
      {/if}
      <div :if={slot_assigned?(@buttons)} class="buttons">
        <#slot {@buttons} />
        <a :on-click="delete" data-confirm="Are you sure?">
          Delete
        </a>
      </div>
    </div>
    """
  end
  @impl true
  def render(%{presentation: :table} = assigns) do
    ~F"""
    <tr {=@id}>
      <td :for={{col,_} <- @columns}>
        <span>{Map.get(@<%= schema.singular %>, col)}</span>
      </td>
      <td>
        <div :if={slot_assigned?(@buttons)} class="buttons">
          <#slot {@buttons} />
          <a :on-click="delete" data-confirm="Are you sure?">
            Delete
          </a>
        </div>
      </td>
    </tr>
    """
  end 

  @impl true
  def render(assigns) do
    ~F"""
    <div>
      <Form
        for={@changeset}
        id={"<%= schema.singular %>-form"}
        change="validate"
        submit={@action == :new && "create" || "update"}
        opts={"phx-target": @myself}
      >
        <%= Mix.Tasks.Phx.Gen.Html.indent_inputs(inputs, 2) %>
        <button phx-disable-with="Saving...">Save <%= schema.human_singular %></button>
      </Form>
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
        ~a|on_create|.(<%= schema.singular %>)

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
        ~a|on_update|.(<%= schema.singular %>)
        socket
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        assign_form(socket, changeset)
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", _, socket) do
    {:ok, _<%= schema.singular %>} = <%= inspect context.alias %>.delete_<%= schema.singular %>(~a[<%= schema.singular %>].id)

    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :changeset, to_form(changeset))
  end
end
