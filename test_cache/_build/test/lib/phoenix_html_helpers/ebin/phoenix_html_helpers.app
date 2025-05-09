{application,phoenix_html_helpers,
    [{config_mtime,1744621395},
     {optional_applications,[plug]},
     {applications,[kernel,stdlib,elixir,logger,phoenix_html,plug]},
     {description,
         "Collection of helpers to generate and manipulate HTML contents"},
     {modules,
         ['Elixir.Phoenix.HTML.FormData.Atom',
          'Elixir.Phoenix.HTML.FormData.Plug.Conn',
          'Elixir.PhoenixHTMLHelpers','Elixir.PhoenixHTMLHelpers.Form',
          'Elixir.PhoenixHTMLHelpers.Format','Elixir.PhoenixHTMLHelpers.Link',
          'Elixir.PhoenixHTMLHelpers.Tag']},
     {registered,[]},
     {vsn,"1.0.1"},
     {env,
         [{csrf_token_reader,
              {'Elixir.Plug.CSRFProtection',get_csrf_token_for,[]}}]}]}.
