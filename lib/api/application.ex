defmodule Api.Application do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("Starting application...")

    config = Application.get_env(:api, Api.Application)
    Logger.info("Configuration: #{inspect(config)}")

    port = config[:http][:port] || 4000
    Logger.info("Configured port: #{port}")

    children = [
      {Plug.Cowboy, scheme: :http, plug: Api.Router, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: Api.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        Logger.info("Application started successfully on port #{port}.")
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Failed to start application: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
