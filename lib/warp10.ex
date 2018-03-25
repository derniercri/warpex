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

  defp map_to_text(%{"ts" => ts, "lat:lon" => latlon, "elev" => elev, "name" => name, "val" => val, "labels" => labels}) do
    "#{ts}/#{latlon}/#{elev} #{name}{#{labels}} #{val}"
  end

  defp map_to_text(%{"ts" => ts, "name" => name, "val" => val, "labels" => labels}) do
    map_to_text(%{"ts" => ts, "name" => name, "val" => val, "labels" => labels, "lat:lon" => "", "elev" => ""})
  end

  def save(data) do
    HTTP.post("/api/v0/update", Enum.map(data, &map_to_text/1))
  end
end
