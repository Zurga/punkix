defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ForgotPasswordLive do
  use <%= inspect context.web_module %>.LiveView
  use <%= inspect context.web_module %>.FormComponent
  alias Surface.Components.Form.EmailInput

  alias <%= inspect context.module %>

  def render(assigns) do
    ~F"""
    <div class="mx-auto max-w-sm">
      <header class="text-center">
        Forgot your password?
        <p>We'll send a password reset link to your inbox</p>
      </header>

      <Form for={@changeset} as={:user} id="reset_password_form" submit="send_email">
<%= Mix.Tasks.Punkix.Gen.Auth.inputs([:email])
 |> Mix.Tasks.Phx.Gen.Html.indent_inputs(8) %>
        <fieldset>
          <button phx-disable-with="Sending..." class="w-full">
            Send password reset instructions
          </button>
        </fieldset>
      </Form>
      <p class="text-center text-sm mt-4">
        <.link href={~p"<%= schema.route_prefix %>/register"}>Register</.link>
        | <.link href={~p"<%= schema.route_prefix %>/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, changeset: Ecto.Changeset.cast({%{}, %{email: :string}}, %{}, [:email]))}
  end

  def handle_event("send_email", %{"<%= schema.singular %>" => %{"email" => email}}, socket) do
    if <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>_by_email(email) do
      <%= inspect context.alias %>.deliver_<%= schema.singular %>_reset_password_instructions(
        <%= schema.singular %>,
        &url(~p"<%= schema.route_prefix %>/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
