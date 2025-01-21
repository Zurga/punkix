import Config

config :punkix, TestRepo,
  username: "postgres",
  password: "postgres",
  database: "punkix_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
