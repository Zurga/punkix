# iex -S mix dev

Logger.configure(level: :debug)

Punkix.Web.Server.start(
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/punkix/web/(live|components)/.*(ex)$",
      ~r"priv/catalogue/.*(ex)$"
    ]
  ]
)
