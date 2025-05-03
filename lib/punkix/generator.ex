defmodule Punkix.Generator do
  defmacro __using__(_env) do
    quote do
      @behaviour Phx.New.Generator
      import Mix.Generator
      import Phx.New.Generator, except: [gen_ecto_config: 2]
      Module.register_attribute(__MODULE__, :templates, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    root = Path.expand("../../templates", __DIR__)

    templates_ast =
      for {name, mappings} <- Module.get_attribute(env.module, :templates) do
        for {format, _proj_location, files} <- mappings,
            format != :keep,
            {source, _target} <- files,
            source = to_string(source) do
          path = Path.join(root, source)

          if format in [:config, :prod_config, :eex] do
            compiled = EEx.compile_file(path)

            quote do
              @external_resource unquote(path)
              @file unquote(path)
              def render(unquote(name), unquote(source), var!(assigns))
                  when is_list(var!(assigns)) do
                var!(maybe_heex_attr_gettext) = &Phx.New.Generator.maybe_heex_attr_gettext/2
                _ = var!(maybe_heex_attr_gettext)
                var!(maybe_eex_gettext) = &Phx.New.Generator.maybe_eex_gettext/2
                _ = var!(maybe_eex_gettext)
                unquote(compiled)
              end
            end
          else
            quote do
              @external_resource unquote(path)
              def render(unquote(name), unquote(source), _assigns), do: unquote(File.read!(path))
            end
          end
        end
      end

    quote do
      unquote(templates_ast)
      def template_files(name), do: Keyword.fetch!(@templates, name)
    end
  end
end
