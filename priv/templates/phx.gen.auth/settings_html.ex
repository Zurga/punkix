defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>SettingsHTML do
  use <%= inspect context.web_module %>.HTML

  embed_templates "<%= schema.singular %>_settings_html/*"
end
