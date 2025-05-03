Application.put_env(:wallaby, :base_url, <%= @endpoint_module %>.url)
ExUnit.start()
