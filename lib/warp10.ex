defmodule Warpex do
  alias Warpex.HTTP

  @moduledoc """
  Documentation for Warpex.
  

  ## Usage
  Add it to your applications and dependencies in `mix.exs`:
      def application do
        [applications: [:warpex]]
      end
      def deps do
        [{:warpex, "~> 1.0"}]
      end
  Configure it in `config.exs`:
      config :warpex,
        address: "http://localhost",  # defaults to System.get_env("WARP10_ADDRESS"),
        read_key:   "xxxxx",  # defaults to System.get_env("WARP10_READ_KEY")
        write_key:  "xxxxx",  # defaults to System.get_env("WARP10_WRITE_KEY")
        httpoison_opts: [timeout: 5000]  # defaults to []
  And then call functions like:
      {status, response} = Warpex.add_event("dinner.tacos", %{test: "tacos"})
  `status` is either `:ok` or `:error`.
  `response` is a Map converted from the JSON response from Keen.
  Information about the contents of the response can be found
  """
end
