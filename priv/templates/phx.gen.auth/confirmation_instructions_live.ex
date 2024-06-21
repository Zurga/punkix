defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ConfirmationInstructionsLive do
  use <%= inspect context.web_module %>.LiveView
  use <%= inspect context.web_module %>.FormComponent
  alias Surface.Components.Form.EmailInput

  alias <%= inspect context.module %>

  def render(assigns) do
    ~F"""
    <div class="mx-auto max-w-sm">
      <header class="text-center">
        No confirmation instructions received?
        <p>We'll send a new confirmation link to your inbox</p>
      </header>

      <Form for={@changeset} id="resend_confirmation_form" submit="send_instructions">
<%= Mix.Tasks.Punkix.Gen.Auth.inputs([:email]) 
 |> Mix.Tasks.Phx.Gen.Html.indent_inputs(8) %>
        <fieldset>
          <button phx-disable-with="Sending..." class="w-full">
            Resend confirmation instructions
          </button>
        </fieldset>
      </Form>

      <p class="text-center mt-4">
        <.link href={~p"<%= schema.route_prefix %>/register"}>Register</.link>
        | <.link href={~p"<%= schema.route_prefix %>/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, changeset: to_form(%{}, as: "<%= schema.singular %>"))}
  end

  def handle_event("send_instructions", %{"<%= schema.singular %>" => %{"email" => email}}, socket) do
    if <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>_by_email(email) do
      <%= inspect context.alias %>.deliver_<%= schema.singular %>_confirmation_instructions(
        <%= schema.singular %>,
        &url(~p"<%= schema.route_prefix %>/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
