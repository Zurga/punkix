defmodule Punkix.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto
      import Ecto.Query
      import Punkix.RepoCase
    end
  end
end
