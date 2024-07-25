defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>LoginLive do
  use <%= inspect context.web_module %>.LiveView
  use <%= inspect context.web_module %>.FormComponent
  alias Surface.Components.Form.{Checkbox, PasswordInput, EmailInput}

  def render(assigns) do
    ~F"""
    <div class="mx-auto max-w-sm">
      <header class="text-center">
        Log in to account
        <p>
          Don't have an account?
          <.link navigate={~p"<%= schema.route_prefix %>/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </p>
      </header>

      <Form for={@changeset} as={:user} id="login_form" action={~p"<%= schema.route_prefix %>/log_in"} opts={["phx-update": "ignore"]}>
<%= Mix.Tasks.Punkix.Gen.Auth.inputs([:email, :password]) 
 |> Mix.Tasks.Phx.Gen.Html.indent_inputs(8) %>

        <fieldset>
          <Field name={:remember_me}>
            <Label>Keep me logged in
              <Checkbox />
            </Label>
          </Field>
          <.link href={~p"<%= schema.route_prefix %>/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </fieldset>
        <fieldset>
          <button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </button>
        </fieldset>
      </Form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    {:ok, assign(socket, changeset: Ecto.Changeset.cast({%{}, %{email: :string}}, %{email: email}, [:email]))}
  end
end
