{application,esbuild,
             [{optional_applications,[inets,ssl]},
              {applications,[kernel,stdlib,elixir,logger,inets,ssl,castore,
                             jason]},
              {description,"Mix tasks for installing and invoking esbuild"},
              {modules,['Elixir.Esbuild','Elixir.Esbuild.NpmRegistry',
                        'Elixir.Mix.Tasks.Esbuild',
                        'Elixir.Mix.Tasks.Esbuild.Install']},
              {registered,[]},
              {vsn,"0.8.2"},
              {mod,{'Elixir.Esbuild',[]}},
              {env,[{default,[]}]}]}.