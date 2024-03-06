defmodule <%= @app_module %>.Repo do
  use Punkix.Repo,
    otp_app: :<%= @app_name %>,
    adapter: <%= inspect @adapter_module %>
end
