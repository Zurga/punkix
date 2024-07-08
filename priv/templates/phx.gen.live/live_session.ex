defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>.LiveSession do
  def on_mount(:<%= schema.plural %>, _params, _session, socket) do
    {:cont, socket}
  end
end
