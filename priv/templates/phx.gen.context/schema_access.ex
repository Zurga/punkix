
  alias <%= inspect schema.module %>
  @<%= schema.singular %>_preloads [<%= Enum.map_join(schema.assocs, ", ", &"#{&1.field}: []" %>]
  @doc """
  Returns the list of <%= schema.plural %>.
  Optionally uses the preloads that are given.

  ## Examples

      iex> list_<%= schema.plural %>()
      [%<%= inspect schema.alias %>{}, ...]

  """
  @spec list_<%= schema.plural %>(nil | []) :: [<%= inspect schema.alias %>.t()]
  def list_<%= schema.plural %>(preloads \\ nil) do
    Repo.all(<%= inspect schema.alias %>)
    |> Repo.maybe_preload(preloads || @<%= schema.singular %>_preloads)
  end

  @doc """
  Gets a single <%= schema.singular %>.
  Optionally uses the preloads that are given.

  Returns {:error, :not_found} if the <%= schema.human_singular %> does not exist.

  ## Examples

      iex> get_<%= schema.singular %>(123)
      %<%= inspect schema.alias %>{}

      iex> get_<%= schema.singular %>(456)
      ** {:error, :not_found}

  """
  @spec get_<%= schema.singular %>(<%= Punkix.spec_alias(schema.alias) %>.id() | String.t(), nil | []) :: 
    {:ok, <%= Punkix.spec_alias(schema.alias) %>.t()} | {:error, :not_found}
  def get_<%= schema.singular %>(id, preloads \\ nil)

  def get_<%= schema.singular %>(id, preloads) when is_binary(id), 
    do: get_<%= schema.singular %>(String.to_integer(id), preloads)

  def get_<%= schema.singular %>(id, preloads) do
    Repo.fetch_one(<%= inspect schema.alias %>, id) 
    |> Repo.maybe_preload(preloads || @<%= schema.singular %>_preloads)
  end

  @doc """
  Creates a <%= schema.singular %>.

  ## Examples

      iex> create_<%= schema.singular %>(<%= Punkix.Context.args_to_params(schema, :create) %>)
      {:ok, %<%= inspect schema.alias %>{}}

      iex> create_<%= schema.singular %>(<%= Punkix.Context.invalid_args_to_params(schema, :create) %>)
      {:error, %Ecto.Changeset{}}

  """
  @spec create_<%= schema.singular %>(<%= Punkix.Context.context_fun_spec(schema, :create) %>, nil | []) :: 
    {:ok, <%= Punkix.spec_alias(schema.alias) %>.t()} | {:error, Ecto.Changeset.t()}
  def create_<%= schema.singular %>(<%= Punkix.Context.context_fun_args(Punkix.Context.required_assocs_as_arguments(schema), schema) %>, preloads \\ nil) do
    <%= if Punkix.Context.required_assocs(schema) != [] do %>Repo.with_assocs(<%= Punkix.Context.build_assocs(schema) %>)<% else %> %<%= inspect schema.alias %>{}<% end %>
    |> store_<%= schema.singular %>(<%= Punkix.Context.context_fun_args(schema) %>, preloads)
  end

  @doc """
  Updates a <%= schema.singular %>.

  ## Examples

      iex> update_<%= schema.singular %>(<%= Punkix.Context.args_to_params("#{schema.singular}.id", schema, :update) %>)
      {:ok, %<%= inspect schema.alias %>{}}

      iex> update_<%= schema.singular %>(<%= schema.singular %>.id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_<%= schema.singular %>(<%= Punkix.Context.context_fun_spec("#{inspect schema.alias}.id()", schema) %>, nil | []) :: 
    {:ok, <%= inspect schema.alias %>.t()} | {:error, :not_found | Ecto.Changeset.t()}
  def update_<%= schema.singular %>(<%= Punkix.Context.context_fun_args("#{schema.singular}_id", schema) %>, preloads \\ nil) do
    with {:ok, <%= schema.singular %>} <- get_<%= schema.singular %>(<%= schema.singular %>_id) do
      store_<%= schema.singular %>(<%= schema.singular %>, <%= Punkix.Context.context_fun_args(schema) %>, preloads)
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
  @spec delete_<%= schema.singular %>(<%= inspect schema.alias %>.id()) :: 
    {:ok, <%= inspect schema.alias %>.t()} | {:error, :not_found | Ecto.Changeset.t()}
  def delete_<%= schema.singular %>(<%= schema.singular %>_id) do
    with {:ok, <%= schema.singular %>} <- get_<%= schema.singular %>(<%= schema.singular %>_id) do
      Repo.delete(<%= schema.singular %>)
    end
  end

  @doc false
  defp store_<%= schema.singular %>(<%= Punkix.Context.context_fun_args(schema.singular, schema) %>, preloads) do
    <%= schema.singular %>
    |> change(<%= Punkix.Context.context_fun_args(schema) %>)
    |> validate_required([<%= Enum.map_join(Mix.Phoenix.Schema.required_fields(schema), ", ", &inspect(elem(&1, 0))) %>])
<%= for k <- schema.uniques do %>    |> unique_constraint(<%= inspect k %>)
<% end %>    |> Repo.insert_or_update()
    |> Repo.maybe_preload(preloads || @<%= schema.singular %>_preloads)
  end
