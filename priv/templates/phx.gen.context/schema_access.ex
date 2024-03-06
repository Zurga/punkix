
  alias <%= inspect schema.module %>

  @doc """
  Returns the list of <%= schema.plural %>.

  ## Examples

      iex> list_<%= schema.plural %>()
      [%<%= inspect schema.alias %>{}, ...]

  """
  @spec list_<%= schema.plural %>() :: [<%= Punkix.spec_alias(schema.alias) %>.t()]
  def list_<%= schema.plural %> do
    Repo.all(<%= inspect schema.alias %>)
  end

  @doc """
  Gets a single <%= schema.singular %>.

  Returns {:error, :not_found} if the <%= schema.human_singular %> does not exist.

  ## Examples

      iex> get_<%= schema.singular %>(123)
      %<%= inspect schema.alias %>{}

      iex> get_<%= schema.singular %>(456)
      ** {:error, :not_found}

  """
  @spec get_<%= schema.singular %>(<%= Punkix.spec_alias(schema.alias) %>.id()) :: 
    {:ok, <%= Punkix.spec_alias(schema.alias) %>.t()} | {:error, :not_found}
  def get_<%= schema.singular %>(id), do: Repo.fetch_one(<%= inspect schema.alias %>, id)

  @doc """
  Creates a <%= schema.singular %>.

  ## Examples

      iex> create_<%= schema.singular %>(<%= Punkix.Context.args_to_params(schema, :update) %>)
      {:ok, %<%= inspect schema.alias %>{}}

      iex> create_<%= schema.singular %>(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_<%= schema.singular %>(<%= Punkix.Context.context_fun_spec(schema) %>) :: 
    {:ok, <%= Punkix.spec_alias(schema.alias) %>.t()} | {:error, Ecto.Changeset.t()}
  def create_<%= schema.singular %>(<%= Punkix.Context.context_fun_args(schema) %>) do
    %<%= inspect schema.alias %>{}
    |> store_<%= schema.singular %>(<%= Punkix.Context.context_fun_args(schema) %>)
  end

  @doc """
  Updates a <%= schema.singular %>.

  ## Examples

      iex> update_<%= schema.singular %>(<%= schema.singular %>.id, <%= Punkix.Context.args_to_params(schema, :update) %>)
      {:ok, %<%= inspect schema.alias %>{}}

      iex> update_<%= schema.singular %>(<%= schema.singular %>.id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_<%= IO.inspect(schema).singular %>(<%= Punkix.spec_alias(schema.alias) %>.id(), <%= Punkix.Context.context_fun_spec(schema) %>) :: 
    {:ok, <%= Punkix.spec_alias(schema.alias) %>.t()} | {:error, :not_found | Ecto.Changeset.t()}
  def update_<%= schema.singular %>(<%= schema.singular %>_id, <%= Punkix.Context.context_fun_args(schema) %>) do
    with {:ok, <%= schema.singular %>} <- Repo.fetch_one(<%= schema.alias %>, <%= schema.singular %>_id) do
      store_<%= schema.singular %>(<%= schema.singular %>, <%= Punkix.Context.context_fun_args(schema) %>)
    end
  end

  @doc """
  Deletes a <%= schema.singular %>.

  ## Examples

      iex> delete_<%= schema.singular %>(<%= schema.singular %>.id)
      {:ok, %<%= inspect schema.alias %>{}}

      iex> delete_<%= schema.singular %>(<%= schema.singular %>.id)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_<%= schema.singular %>(<%= Punkix.spec_alias(schema.alias) %>.id()) :: 
    {:ok, <%= Punkix.spec_alias(schema.alias) %>.t()} | {:error, :not_found | Ecto.Changeset.t()}
  def delete_<%= schema.singular %>(<%= schema.singular %>_id) do
    with {:ok, <%= schema.singular %>} <- Repo.fetch_one(<%= schema.alias %>, <%= schema.singular %>_id) do
      Repo.delete(<%= schema.singular %>)
    end
  end

  @doc false
  defp store_<%= schema.singular %>(<%= schema.singular %>, <%= Punkix.Context.context_fun_args(schema) %>) do
    <%= schema.singular %>
    |> change(<%= Enum.map_join(schema.attrs, ", ", &"#{elem(&1, 0)}: #{elem(&1, 0)}") %>)
    |> validate_required([<%= Enum.map_join(Mix.Phoenix.Schema.required_fields(schema), ", ", &inspect(elem(&1, 0))) %>])
<%= for k <- schema.uniques do %>    |> unique_constraint(<%= inspect k %>)
<% end %>    |> Repo.insert_or_update()
  end
