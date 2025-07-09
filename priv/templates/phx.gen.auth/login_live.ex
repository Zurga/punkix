defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>LoginLive do
  use <%= inspect context.web_module %>.LiveView
  use <%= inspect context.web_module %>.FormComponent
  alias Surface.Components.Form.{Checkbox, PasswordInput, EmailInput}

  def render(assigns) do
    ~F"""
    <article>
      <header>
        Log in to account
        <p>
          Don't have an account?
          <.link navigate={~p"<%= schema.route_prefix %>/register"}>
            <strong>Sign up</strong> 
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
          <.link href={~p"<%= schema.route_prefix %>/reset_password"}>
            Forgot your password?
          </.link>
        </fieldset>
        <fieldset>
          <button phx-disable-with="Logging in...">
            Log in <span aria-hidden="true">→</span>
          </button>
        </fieldset>
      </Form>
    </article>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    {:ok, assign(socket, changeset: Ecto.Changeset.cast({%{}, %{email: :string}}, %{email: email}, [:email]))}
  end
end
