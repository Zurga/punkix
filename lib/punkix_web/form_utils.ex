defmodule PunkixWeb.FormUtils do
  def wrap_input(key, input, label \\ nil) do
    ~s"""
    <Field name={#{inspect(key)}}>
      <Label>#{label || label(key)}</Label>
      <#{input} />
      <ErrorTag />
    </Field>
    """
  end

  def label(key), do: Phoenix.Naming.humanize(to_string(key))
end
