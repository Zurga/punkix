  alias <%= inspect context.module %>.<%= inspect schema.alias %>Notifier
  alias <%= inspect context.base_module %>.Schemas.<%= inspect context.alias %>.{<%= inspect schema.alias %>, <%= inspect schema.alias %>Token}

  ## Database getters

  @doc """
  Gets a <%= schema.singular %> by email.

  ## Examples

      iex> get_<%= schema.singular %>_by_email("foo@example.com")
      %<%= inspect schema.alias %>{}

      iex> get_<%= schema.singular %>_by_email("unknown@example.com")
      nil

  """
  def get_<%= schema.singular %>_by_email(email) when is_binary(email) do
    Repo.get_by(<%= inspect schema.alias %>, email: email)
  end

  @doc """
  Gets a <%= schema.singular %> by email and password.

  ## Examples

      iex> get_<%= schema.singular %>_by_email_and_password("foo@example.com", "correct_password")
      %<%= inspect schema.alias %>{}

      iex> get_<%= schema.singular %>_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_<%= schema.singular %>_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    <%= schema.singular %> = Repo.get_by(<%= inspect schema.alias %>, email: email)
    if valid_password?(<%= schema.singular %>, password), do: <%= schema.singular %>
  end

  @doc """
  Gets a single <%= schema.singular %>.

  Raises `Ecto.NoResultsError` if the <%= inspect schema.alias %> does not exist.

  ## Examples

      iex> get_<%= schema.singular %>!(123)
      %<%= inspect schema.alias %>{}

      iex> get_<%= schema.singular %>!(456)
      ** (Ecto.NoResultsError)

  """
  def get_<%= schema.singular %>!(id), do: Repo.get!(<%= inspect schema.alias %>, id)

  ## <%= schema.human_singular %> registration

  @doc """
  Registers a <%= schema.singular %>.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.

  ## Examples

      iex> register_<%= schema.singular %>(%{field: value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> register_<%= schema.singular %>(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_<%= schema.singular %>(attrs, opts \\ []) do
    %<%= inspect schema.alias %>{}
    |> registration_changeset(attrs, opts)
    |> Repo.insert()
  end

  def registration_changeset(<%= schema.singular %>, attrs, opts) do
    <%= schema.singular %>
    |> cast(attrs, [:email, :password])
    |> validate_email(opts)
    |> validate_password(opts)
  end
    
  @doc """
  Returns an `%Ecto.Changeset{}` for tracking <%= schema.singular %> changes.

  ## Examples

      iex> change_<%= schema.singular %>_registration(<%= schema.singular %>)
      %Ecto.Changeset{data: %<%= inspect schema.alias %>{}}

  """
  def change_<%= schema.singular %>_registration(%<%= inspect schema.alias %>{} = <%= schema.singular %>, attrs \\ %{}) do
    registration_changeset(<%= schema.singular %>, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the <%= schema.singular %> email.

  ## Examples

      iex> change_<%= schema.singular %>_email(<%= schema.singular %>)
      %Ecto.Changeset{data: %<%= inspect schema.alias %>{}}

  """
  def change_<%= schema.singular %>_email(<%= schema.singular %>, attrs \\ %{}) do
    email_changeset(<%= schema.singular %>, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_<%= schema.singular %>_email(<%= schema.singular %>, "valid password", %{email: ...})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> apply_<%= schema.singular %>_email(<%= schema.singular %>, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_<%= schema.singular %>_email(<%= schema.singular %>, password, attrs) do
    <%= schema.singular %>
    |> email_changeset(attrs)
    |> validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the <%= schema.singular %> email using the given token.

  If the token matches, the <%= schema.singular %> email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_<%= schema.singular %>_email(<%= schema.singular %>, token) do
    context = "change:#{<%= schema.singular %>.email}"

    with {:ok, query} <- <%= inspect schema.alias %>Token.verify_change_email_token_query(token, context),
         %<%= inspect schema.alias %>Token{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(<%= schema.singular %>_email_multi(<%= schema.singular %>, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp <%= schema.singular %>_email_multi(<%= schema.singular %>, email, context) do
    changeset =
      <%= schema.singular %>
      |> email_changeset(%{email: email})
      |> confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:<%= schema.singular %>, changeset)
    |> Ecto.Multi.delete_all(:tokens, <%= inspect schema.alias %>Token.by_<%= schema.singular %>_and_contexts_query(<%= schema.singular %>, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given <%= schema.singular %>.

  ## Examples

      iex> deliver_<%= schema.singular %>_update_email_instructions(<%= schema.singular %>, current_email, &url(~p"<%= schema.route_prefix %>/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_<%= schema.singular %>_update_email_instructions(%<%= inspect schema.alias %>{} = <%= schema.singular %>, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, <%= schema.singular %>_token} = <%= inspect schema.alias %>Token.build_email_token(<%= schema.singular %>, "change:#{current_email}")

    Repo.insert!(<%= schema.singular %>_token)
    <%= inspect schema.alias %>Notifier.deliver_update_email_instructions(<%= schema.singular %>, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the <%= schema.singular %> password.

  ## Examples

      iex> change_<%= schema.singular %>_password(<%= schema.singular %>)
      %Ecto.Changeset{data: %<%= inspect schema.alias %>{}}

  """
  def change_<%= schema.singular %>_password(<%= schema.singular %>, attrs \\ %{}) do
    password_changeset(<%= schema.singular %>, attrs, hash_password: false)
  end

  @doc """
  Updates the <%= schema.singular %> password.

  ## Examples

      iex> update_<%= schema.singular %>_password(<%= schema.singular %>, "valid password", %{password: ...})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> update_<%= schema.singular %>_password(<%= schema.singular %>, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_<%= schema.singular %>_password(<%= schema.singular %>, password, attrs) do
    changeset =
      <%= schema.singular %>
      |> password_changeset(attrs)
      |> validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:<%= schema.singular %>, changeset)
    |> Ecto.Multi.delete_all(:tokens, <%= inspect schema.alias %>Token.by_<%= schema.singular %>_and_contexts_query(<%= schema.singular %>, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{<%= schema.singular %>: <%= schema.singular %>}} -> {:ok, <%= schema.singular %>}
      {:error, :<%= schema.singular %>, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_<%= schema.singular %>_session_token(<%= schema.singular %>) do
    {token, <%= schema.singular %>_token} = <%= inspect schema.alias %>Token.build_session_token(<%= schema.singular %>)
    Repo.insert!(<%= schema.singular %>_token)
    token
  end

  @doc """
  Gets the <%= schema.singular %> with the given signed token.
  """
  def get_<%= schema.singular %>_by_session_token(token) do
    {:ok, query} = <%= inspect schema.alias %>Token.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_<%= schema.singular %>_session_token(token) do
    Repo.delete_all(<%= inspect schema.alias %>Token.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given <%= schema.singular %>.

  ## Examples

      iex> deliver_<%= schema.singular %>_confirmation_instructions(<%= schema.singular %>, &url(~p"<%= schema.route_prefix %>/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_<%= schema.singular %>_confirmation_instructions(confirmed_<%= schema.singular %>, &url(~p"<%= schema.route_prefix %>/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_<%= schema.singular %>_confirmation_instructions(%<%= inspect schema.alias %>{} = <%= schema.singular %>, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if <%= schema.singular %>.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, <%= schema.singular %>_token} = <%= inspect schema.alias %>Token.build_email_token(<%= schema.singular %>, "confirm")
      Repo.insert!(<%= schema.singular %>_token)
      <%= inspect schema.alias %>Notifier.deliver_confirmation_instructions(<%= schema.singular %>, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a <%= schema.singular %> by the given token.

  If the token matches, the <%= schema.singular %> account is marked as confirmed
  and the token is deleted.
  """
  def confirm_<%= schema.singular %>(token) do
    with {:ok, query} <- <%= inspect schema.alias %>Token.verify_email_token_query(token, "confirm"),
         %<%= inspect schema.alias %>{} = <%= schema.singular %> <- Repo.one(query),
         {:ok, %{<%= schema.singular %>: <%= schema.singular %>}} <- Repo.transaction(confirm_<%= schema.singular %>_multi(<%= schema.singular %>)) do
      {:ok, <%= schema.singular %>}
    else
      _ -> :error
    end
  end

  defp confirm_<%= schema.singular %>_multi(<%= schema.singular %>) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:<%= schema.singular %>, confirm_changeset(<%= schema.singular %>))
    |> Ecto.Multi.delete_all(:tokens, <%= inspect schema.alias %>Token.by_<%= schema.singular %>_and_contexts_query(<%= schema.singular %>, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given <%= schema.singular %>.

  ## Examples

      iex> deliver_<%= schema.singular %>_reset_password_instructions(<%= schema.singular %>, &url(~p"<%= schema.route_prefix %>/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_<%= schema.singular %>_reset_password_instructions(%<%= inspect schema.alias %>{} = <%= schema.singular %>, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, <%= schema.singular %>_token} = <%= inspect schema.alias %>Token.build_email_token(<%= schema.singular %>, "reset_password")
    Repo.insert!(<%= schema.singular %>_token)
    <%= inspect schema.alias %>Notifier.deliver_reset_password_instructions(<%= schema.singular %>, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the <%= schema.singular %> by reset password token.

  ## Examples

      iex> get_<%= schema.singular %>_by_reset_password_token("validtoken")
      %<%= inspect schema.alias %>{}

      iex> get_<%= schema.singular %>_by_reset_password_token("invalidtoken")
      nil

  """
  def get_<%= schema.singular %>_by_reset_password_token(token) do
    with {:ok, query} <- <%= inspect schema.alias %>Token.verify_email_token_query(token, "reset_password"),
         %<%= inspect schema.alias %>{} = <%= schema.singular %> <- Repo.one(query) do
      <%= schema.singular %>
    else
      _ -> nil
    end
  end

  @doc """
  Resets the <%= schema.singular %> password.

  ## Examples

      iex> reset_<%= schema.singular %>_password(<%= schema.singular %>, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> reset_<%= schema.singular %>_password(<%= schema.singular %>, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_<%= schema.singular %>_password(<%= schema.singular %>, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:<%= schema.singular %>, password_changeset(<%= schema.singular %>, attrs))
    |> Ecto.Multi.delete_all(:tokens, <%= inspect schema.alias %>Token.by_<%= schema.singular %>_and_contexts_query(<%= schema.singular %>, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{<%= schema.singular %>: <%= schema.singular %>}} -> {:ok, <%= schema.singular %>}
      {:error, :<%= schema.singular %>, changeset, _} -> {:error, changeset}
    end
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset<%= if hashing_library.name == :bcrypt do %>
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)<% end %>
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, <%= inspect hashing_library.module %>.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset = changeset
      |> unsafe_validate_unique(:email, <%= inspect schema.repo %>)
      |> unique_constraint(:email)

      errors = changeset.errors
        |> Enum.map(fn {field, {msg, opts}} ->
          {field, {msg, Enum.flat_map(opts, fn {key, value} when is_list(value) ->
              Enum.map(value, &{key, &1})
            {key, value} -> [{key, value}]
          end)}}        
        end)
      %{changeset | errors: errors}
    else
      changeset
    end
  end

  @doc """
  A <%= schema.singular %> changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(<%= schema.singular %>, attrs, opts \\ []) do
    <%= schema.singular %>
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A <%= schema.singular %> changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(<%= schema.singular %>, attrs, opts \\ []) do
    <%= schema.singular %>
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(<%= schema.singular %>) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(<%= schema.singular %>, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no <%= schema.singular %> or the <%= schema.singular %> doesn't have a password, we call
  `<%= inspect hashing_library.module %>.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%<%= inspect schema.module %>{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    <%= inspect hashing_library.module %>.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    <%= inspect hashing_library.module %>.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
