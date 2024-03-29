defmodule Punkix.Patcher do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :wrappers, accumulate: true)
      Module.register_attribute(__MODULE__, :replacers, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    wrappers = Module.get_attribute(env.module, :wrappers)
    replacers = Module.get_attribute(env.module, :replacers)

    affected_modules =
      [wrappers, replacers]
      |> Enum.flat_map(fn rule -> Enum.map(rule, &elem(&1, 0)) end)
      |> Enum.uniq()

    module_map =
      Enum.reduce(affected_modules, %{}, fn module, acc ->
        wrappers = Enum.filter(wrappers, &(elem(&1, 0) == module))
        replacers = Enum.filter(replacers, &(elem(&1, 0) == module))
        Map.put(acc, module, %{wrap: wrappers, replace: replacers})
      end)

    for {module, modifications} <- module_map do
      abstract_code(module)
      |> wrap_function(modifications[:wrap], env.module)
      |> replace_function(modifications[:replace], env.module)
      |> compile()
    end

    for {_module, %{wrap: modifications}} <- module_map do
      Enum.map(modifications, fn
        {_, function, arity, wrapper} ->
          quote do
            def wrap({unquote(function), unquote(arity)}, fun) do
              result = unquote(wrapper)(fun.())
              result
            end
          end

        {_, function, wrapper} ->
          quote do
            def wrap({unquote(function)}, fun) do
              result = unquote(wrapper)(fun.())
              result
            end
          end
      end)
    end
  end

  defmacro wrap(module, function, wrapping_function) when is_atom(wrapping_function) do
    quote do
      @wrappers {unquote(module), unquote(function), nil, unquote(wrapping_function)}
    end
  end

  defmacro wrap(module, function, arity, wrapping_function) do
    quote do
      @wrappers {unquote(module), unquote(function), unquote(arity), unquote(wrapping_function)}
    end
  end

  defmacro replace(module, function, arity, replacement_function) do
    quote do
      @replacers {unquote(module), unquote(function), unquote(arity),
                  unquote(replacement_function)}
    end
  end

  def abstract_code(module) do
    {_, beam, _} = :code.get_object_code(module)

    {:ok, {_, [{:abstract_code, {:raw_abstract_v1, code}}]}} =
      :beam_lib.chunks(beam, ~w/abstract_code/a)

    code
  end

  def export_functions(nil), do: nil

  def export_functions(code, functions) do
    {:attribute, line, :export, exports} = List.keyfind(code, :export, 2)

    attr = {:attribute, line, :export, exports ++ functions}

    List.keyreplace(code, :export, 2, attr)
  end

  def replace_function(code, [], _), do: code

  def replace_function(code, replacers, wrapping_module) when is_list(replacers),
    do: Enum.reduce(replacers, code, &replace_function(&2, &1, wrapping_module))

  def replace_function(code, {_module, function, arity, remote_function}, wrapping_module) do
    modify_function(
      code,
      function,
      arity,
      &replace_body(&1, wrapping_module, remote_function)
    )
  end

  def wrap_function(code, nil, _), do: code

  def wrap_function(code, mfws, wrapping_module) when is_list(mfws) do
    Enum.reduce(mfws, code, &wrap_function(&2, &1, wrapping_module))
  end

  def wrap_function(code, {_module, function, _}, wrapping_module) do
    do_wrap_function(code, function, nil, wrapping_module)
  end

  def wrap_function(code, {_module, function, arity, _}, wrapping_module) do
    do_wrap_function(code, function, arity, wrapping_module)
  end

  defp do_wrap_function(code, function, arity, wrapping_module) do
    code
    |> modify_function(function, arity, &wrap_abstract_function(&1, wrapping_module))
  end

  defp modify_function(code, function, arity, func) do
    Enum.reduce(code, [], fn
      {:function, _, ^function, func_arity, _} = function_to_wrap, acc
      when is_nil(arity) or arity == func_arity ->
        [func.(function_to_wrap) | acc]

      line, acc ->
        [line | acc]
    end)
    |> Enum.reverse()
  end

  defp wrap_abstract_function(function_tuple, wrapping_module) do
    {:function, line, function, arity, [{:clause, clause_line, args, guards, body}]} =
      function_tuple

    body = [
      {:call, line, {:remote, line, {:atom, line, wrapping_module}, {:atom, line, :wrap}},
       [
         {:tuple, line, [{:atom, line, function}, {:integer, line, arity}]},
         # {:tuple, line, args |> IO.inspect()},
         {:fun, line, {:clauses, [{:clause, line, [], [], body}]}}
       ]}
    ]

    {:function, line, function, arity, [{:clause, clause_line, args, guards, body}]}
  end

  def replace_body(function_tuple, remote_module, remote_function) do
    {:function, line, function, arity, [{:clause, clause_line, args, guards, _body}]} =
      function_tuple

    body = [
      {:call, line, {:remote, line, {:atom, line, remote_module}, {:atom, line, remote_function}},
       args}
    ]

    {:function, line, function, arity, [{:clause, clause_line, args, guards, body}]}
  end

  defp compile(code) do
    {:ok, modname, binary} = :compile.forms(code)
    :code.load_binary(modname, [], binary)
  end
end
