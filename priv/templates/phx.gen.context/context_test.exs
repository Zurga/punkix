defmodule <%= inspect context.module %>Test do
  use <%= inspect context.base_module %>.DataCase
  use Mneme

  alias <%= inspect context.module %>
end
