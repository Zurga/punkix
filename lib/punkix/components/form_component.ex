defmodule Punkix.FormComponent do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def to_form_struct(struct, form_module, fields) do
    fields =
      Map.from_struct(struct)
      |> Map.take(fields)

    struct(form_module, fields)
  end
end
