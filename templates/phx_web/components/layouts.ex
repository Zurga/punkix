defmodule <%= @web_namespace %>.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use <%= @web_namespace %>.Controller` and
  `use <%= @web_namespace %>.LiveView`.
  """
  use <%= @web_namespace %>.HTML

  embed_templates "layouts/*"
end
