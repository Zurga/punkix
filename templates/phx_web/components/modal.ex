defmodule <%= @web_namespace %>.Components.Modal do
  use <%= @web_namespace %>.Component

  prop id, :string, required: true
  prop show, :boolean
  prop on_cancel, :fun
  slot default
  slot title

  def render(assigns) do
    ~F"""
      <dialog open={@show}>
        <article>
          <header>
            <button rel="prev" phx-click={@on_cancel || JS.toggle_attribute({"open", "false"}, to: "##{@id}")}>Close</button>
            <#slot {@title} />
          </header>
          <#slot />
        </article>
      </dialog>
    """
  end
end
