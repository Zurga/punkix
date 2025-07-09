defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>RegistrationLive do
  use <%= inspect context.web_module %>.LiveView
  use <%= inspect context.web_module %>.FormComponent
  alias Surface.Components.Form.{EmailInput, PasswordInput}

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>

  def render(assigns) do
    ~F"""
    <article>
      <header>
        Register for an account
        <p>
          Already registered?
          <.link navigate={~p"<%= schema.route_prefix %>/log_in"}>
            <strong>Log in</strong>
          </.link>
          to your account now.
        </p>
      </header>

      <Form
        for={@changeset}
        id="registration_form"
        submit="save"
        change="validate"
        opts={["phx-trigger-action": @trigger_submit]}
        action={~p"<%= schema.route_prefix %>/log_in?_action=registered"}
        method="post"
      >
        <p class="error" :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </p>
        <%= Mix.Tasks.Punkix.Gen.Auth.inputs([:email, :password])
         |> Mix.Tasks.Phx.Gen.Html.indent_inputs(8) %>

        <fieldset>
          <button phx-disable-with="Creating account...">Create an account</button>
        </fieldset>
      </Form>
    </article>
    """
  end

  def mount(_params, _session, socket) do
    changeset = <%= inspect context.alias %>.change_<%= schema.singular %>_registration(%<%= inspect schema.alias %>{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  def handle_event("save", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    case <%= inspect context.alias %>.register_<%= schema.singular %>(<%= schema.singular %>_params) do
      {:ok, <%= schema.singular %>} ->
        {:ok, _} =
          <%= inspect context.alias %>.deliver_<%= schema.singular %>_confirmation_instructions(
            <%= schema.singular %>,
            &url(~p"<%= schema.route_prefix %>/confirm/#{&1}")
          )

        changeset = <%= inspect context.alias %>.change_<%= schema.singular %>_registration(<%= schema.singular %>)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    changeset = <%= inspect context.alias %>.change_<%= schema.singular %>_registration(%<%= inspect schema.alias %>{}, <%= schema.singular %>_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, changeset: changeset)
  end
end
