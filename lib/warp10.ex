defmodule Warp10 do
  alias Warp10.HTTP

  @moduledoc """
  Documentation for Warp10.
  

  ## Usage
  Add it to your applications and dependencies in `mix.exs`:
      def application do
        [applications: [:warp10]]
      end
      def deps do
        [{:warp10, "~> 1.0"}]
      end
  Configure it in `config.exs`:
      config :warp10,
        address: "http://localhost",  # defaults to System.get_env("WARP10_ADDRESS"),
        read_key:   "xxxxx",  # defaults to System.get_env("WARP10_READ_KEY")
        write_key:  "xxxxx",  # defaults to System.get_env("WARP10_WRITE_KEY")
        httpoison_opts: [timeout: 5000]  # defaults to []
  And then call functions like:
      {status, response} = Warp10.add_event("dinner.tacos", %{test: "tacos"})
  `status` is either `:ok` or `:error`.
  `response` is a Map converted from the JSON response from Keen.
  Information about the contents of the response can be found
  """
end
