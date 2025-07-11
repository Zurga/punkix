defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>SettingsLive do
  use <%= inspect context.web_module %>.LiveView
  use <%= inspect context.web_module %>.FormComponent
  alias Surface.Components.Form.{Checkbox, EmailInput, HiddenInput, PasswordInput, TextInput}

  alias <%= inspect context.module %>

  def render(assigns) do
    ~F"""
    <article>
    <header>
      Account Settings
      <p>Manage your account email address and password settings</p>
    </header>
      <div>

        <Form
          for={@email_form}
          id="email_form"
          submit="update_email"
          change="validate_email"
        >
          <%= Mix.Tasks.Punkix.Gen.Auth.inputs([:email]) 
           |> Mix.Tasks.Phx.Gen.Html.indent_inputs(8) %>
          <Field name={:current_password}>
            <Label>Current password</Label>
            <PasswordInput name="current_password" value={@email_form_current_password} />
            <ErrorTag />
          </Field>
          <fieldset>
            <button phx-disable-with="Changing...">Change Email</button>
          </fieldset>
        </Form>
      </div>
      <div>
        <Form
          for={@password_form}
          id="password_form"
          action={~p"<%= schema.route_prefix %>/log_in?_action=password_updated"}
          method="post"
          submit="update_password"
          change="validate_password"
          opts={["phx-trigger-action": @trigger_submit]}
        >
          <HiddenInput
            name={@password_form[:email].name}
            id="hidden_<%= schema.singular %>_email"
            value={@current_email}
          />
          <%= Mix.Tasks.Punkix.Gen.Auth.inputs([:password, :password_confirmation])
           |> Mix.Tasks.Phx.Gen.Html.indent_inputs(8) %>
          <PasswordInput
            field={:current_password}
            name="current_password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
          />
          <fieldset>
            <button phx-disable-with="Changing...">Change Password</button>
          </fieldset>
        </Form>
      </div>
    </article>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case <%= inspect context.alias %>.update_<%= schema.singular %>_email(socket.assigns.current_<%= schema.singular %>, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"<%= schema.route_prefix %>/settings")}
  end

  def mount(_params, _session, socket) do
    <%= schema.singular %> = socket.assigns.current_<%= schema.singular %>
    email_changeset = <%= inspect context.alias %>.change_<%= schema.singular %>_email(<%= schema.singular %>)
    password_changeset = <%= inspect context.alias %>.change_<%= schema.singular %>_password(<%= schema.singular %>)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, <%= schema.singular %>.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "<%= schema.singular %>" => <%= schema.singular %>_params} = params

    email_form =
      socket.assigns.current_<%= schema.singular %>
      |> <%= inspect context.alias %>.change_<%= schema.singular %>_email(<%= schema.singular %>_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "<%= schema.singular %>" => <%= schema.singular %>_params} = params
    <%= schema.singular %> = socket.assigns.current_<%= schema.singular %>

    case <%= inspect context.alias %>.apply_<%= schema.singular %>_email(<%= schema.singular %>, password, <%= schema.singular %>_params) do
      {:ok, applied_<%= schema.singular %>} ->
        <%= inspect context.alias %>.deliver_<%= schema.singular %>_update_email_instructions(
          applied_<%= schema.singular %>,
          <%= schema.singular %>.email,
          &url(~p"<%= schema.route_prefix %>/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "<%= schema.singular %>" => <%= schema.singular %>_params} = params

    password_form =
      socket.assigns.current_<%= schema.singular %>
      |> <%= inspect context.alias %>.change_<%= schema.singular %>_password(<%= schema.singular %>_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "<%= schema.singular %>" => <%= schema.singular %>_params} = params
    <%= schema.singular %> = socket.assigns.current_<%= schema.singular %>

    case <%= inspect context.alias %>.update_<%= schema.singular %>_password(<%= schema.singular %>, password, <%= schema.singular %>_params) do
      {:ok, <%= schema.singular %>} ->
        password_form =
          <%= schema.singular %>
          |> <%= inspect context.alias %>.change_<%= schema.singular %>_password(<%= schema.singular %>_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
