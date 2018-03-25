defmodule Warp10.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    #children = [
      # Starts a worker by calling: Warp10.Worker.start_link(arg)
      # {Warp10.Worker, arg},
    #]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    #opts = [strategy: :one_for_one, name: Warp10.Supervisor]
    #Supervisor.start_link(children, opts)

    address = Application.get_env(:warp10, :address, System.get_env("WARP10_ADDRESS"))
    read_key = Application.get_env(:warp10, :address, System.get_env("WARP10_READ_KEY"))
    write_key = Application.get_env(:warp10, :address, System.get_env("WARP10_WRITE_KEY"))

    httpoison_opts = Application.get_env(:keenex, :httpoison_opts, [])

    config = %{
      address: address,
      write_key: write_key,
      read_key: read_key,
      httpoison_opts: httpoison_opts,
    }
    Agent.start_link(fn -> config end, name: __MODULE__)
  end
end
