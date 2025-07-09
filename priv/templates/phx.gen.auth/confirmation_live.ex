defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ConfirmationLive do
  use <%= inspect context.web_module %>.LiveView
  use <%= inspect context.web_module %>.FormComponent
  import Phoenix.HTML.Form, only: [input_value: 2]
  alias Surface.Components.Form.HiddenInput

  alias <%= inspect context.module %>

  def render(%{live_action: :edit} = assigns) do
    ~F"""
    <article>
      <header>Confirm Account</header>

      <Form for={@changeset} :let={form: form} as={:<%= schema.singular %>} id="confirmation_form" submit="confirm_account">
        <Field name={:token}>
          <HiddenInput value={input_value(form, :token)} />
        </Field>
        <button phx-disable-with="Confirming..." class="w-full">Confirm my account</button>
      </Form>

      <p>
        <.link href={~p"<%= schema.route_prefix %>/register"}>Register</.link>
        | <.link href={~p"<%= schema.route_prefix %>/log_in"}>Log in</.link>
      </p>
    </article>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    
    {:ok, assign(socket, changeset: Ecto.Changeset.cast({%{}, %{token: :string}}, %{token: token}, [:token])), temporary_assigns: [form: nil]}
  end

  # Do not log in the <%= schema.singular %> after confirmation to avoid a
  # leaked token giving the <%= schema.singular %> access to the account.
  def handle_event("confirm_account", %{"<%= schema.singular %>" => %{"token" => token}}, socket) do
    case <%= inspect context.alias %>.confirm_<%= schema.singular %>(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "<%= inspect schema.alias %> confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current <%= schema.singular %> and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the <%= schema.singular %> themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_<%= schema.singular %>: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "<%= inspect schema.alias %> confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
