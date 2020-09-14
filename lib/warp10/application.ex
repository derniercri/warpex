defmodule Warpex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    address = Application.get_env(:warpex, :address, System.get_env("WARP10_ADDRESS"))
    read_key = Application.get_env(:warpex, :read_key, System.get_env("WARP10_READ_KEY"))
    write_key = Application.get_env(:warpex, :write_key, System.get_env("WARP10_WRITE_KEY"))

    httpoison_opts = Application.get_env(:warpex, :httpoison_opts, [])

    config = %{
      address: address,
      write_key: write_key,
      read_key: read_key,
      httpoison_opts: httpoison_opts
    }

    Agent.start_link(fn -> config end, name: __MODULE__)
  end

  @doc false
  def get_key(key_type) do
    case key_type do
      :write ->
        Agent.get(__MODULE__, fn state -> state.write_key end)

      :read ->
        Agent.get(__MODULE__, fn state -> state.read_key end)
    end
  end

  @doc false
  def address() do
    Agent.get(__MODULE__, fn state -> state.address end)
  end

  @doc false
  def httpoison_opts() do
    Agent.get(__MODULE__, fn state -> state.httpoison_opts end)
  end
end
