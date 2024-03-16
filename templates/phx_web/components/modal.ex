defmodule <%= @web_namespace %>.Components.Modal do
  use <%= @web_namespace %>.Component

  prop id, :string, required: true
  prop show, :boolean
  slot default

  def render(assigns) do
    ~F"""
      <dialog open={@show}>
        <article>
          <header>
            <button autofocus phx-click={JS.toggle_attribute({"open", "false"}, to: "##{@id}")}>Close</button>
          </header>
          <#slot />
        </article>
      </dialog>
    """
  end
end
