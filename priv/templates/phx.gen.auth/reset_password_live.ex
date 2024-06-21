defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ResetPasswordLive do
  use <%= inspect context.web_module %>.LiveView
  use <%= inspect context.web_module %>.FormComponent
  alias Surface.Components.Form.PasswordInput

  alias <%= inspect context.module %>

  def render(assigns) do
    ~F"""
    <div class="mx-auto max-w-sm">
      <header class="text-center">Reset Password</header>

      <Form
        for={@changeset}
        id="reset_password_form"
        submit="reset_password"
        change="validate"
      >
        <p class="error" :if={@changeset.errors != []}>
          Oops, something went wrong! Please check the errors below.
        </p>

<%= Mix.Tasks.Punkix.Gen.Auth.inputs([:password, {:password_confirmation, "Confirm new password"}]) 
 |> Mix.Tasks.Phx.Gen.Html.indent_inputs(8) %>
        <fieldset>
          <button phx-disable-with="Resetting..." class="w-full">Reset Password</button>
        </fieldset>
      </Form>

      <p class="text-center text-sm mt-4">
        <.link href={~p"<%= schema.route_prefix %>/register"}>Register</.link>
        | <.link href={~p"<%= schema.route_prefix %>/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_<%= schema.singular %>_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{<%= schema.singular %>: <%= schema.singular %>} ->
          <%= inspect context.alias %>.change_<%= schema.singular %>_password(<%= schema.singular %>)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  # Do not log in the <%= schema.singular %> after reset password to avoid a
  # leaked token giving the <%= schema.singular %> access to the account.
  def handle_event("reset_password", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    case <%= inspect context.alias %>.reset_<%= schema.singular %>_password(socket.assigns.<%= schema.singular %>, <%= schema.singular %>_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"<%= schema.route_prefix %>/log_in")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    changeset = <%= inspect context.alias %>.change_<%= schema.singular %>_password(socket.assigns.<%= schema.singular %>, <%= schema.singular %>_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_<%= schema.singular %>_and_token(socket, %{"token" => token}) do
    if <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>_by_reset_password_token(token) do
      assign(socket, <%= schema.singular %>: <%= schema.singular %>, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, changeset: source)
  end
end
