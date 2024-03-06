defmodule <%= inspect context.module %> do
  @moduledoc """
  The <%= context.name %> context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias <%= inspect schema.repo %><%= # TODO add this back schema.repo_alias %>
end
