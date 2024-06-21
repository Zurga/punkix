defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Component do
  use <%= inspect context.web_module %>.Component

  prop <%= schema.singular %>, :struct, required: true
  prop action, :atom, default: :new
  prop patch, :string
  
  @impl true
  def render(assigns) do
    ~F"""
      <div>
        {if action in [:new, :edit]}
            <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Component}
        {/if}
      </div>
    """
  end
end
