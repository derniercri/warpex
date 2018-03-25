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

  defp map_to_text([h | t], content) do
    map_to_text(t, "#{content}\n#{transform_item(h)}" )
  end

  defp map_to_text([], content) do
    content        
  end

  defp transform_item(%{"ts" => ts, "lat:lon" => latlon, "elev" => elev, "name" => name, "val" => val, "labels" => labels}) do
    "#{ts}/#{latlon}/#{elev} #{name}{#{labels}} #{val}"
  end

  defp transform_item(%{"ts" => ts, "name" => name, "val" => val, "labels" => labels}) do
    transform_item(%{"ts" => ts, "name" => name, "val" => val, "labels" => labels, "lat:lon" => "", "elev" => ""})
  end

  def update(data) do
    HTTP.post("/api/v0/update", map_to_text(data, ""))
  end

  def fetch(selector, start, stop) do
    HTTP.get("/api/v0/fetch", %{selector: selector, start: DateTime.to_iso8601(start), stop: DateTime.to_iso8601(stop)})
  end

  def parse_result(data) do
    HTTP.parse_response(String.split(data, "\n"), %{}, [])
  end
end
