import Config

esbuild = fn args ->
  [
    args: ~w(./js/punkix --bundle) ++ args,
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]
end

config :esbuild,
  version: "0.12.15",
  module: esbuild.(~w(--format=esm --sourcemap --outfile=../priv/static/punkix.esm.js)),
  main: esbuild.(~w(--format=cjs --sourcemap --outfile=../priv/static/punkix.cjs.js))

import_config "#{config_env()}.exs"
