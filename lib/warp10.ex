defmodule Warpex do
  alias Warpex.HTTP
  alias Warpex.Application

  @moduledoc """
  Documentation for Warpex.

  ## Usage
  Add it to your applications and dependencies in `mix.exs`:
      def application do
        [applications: [:warpex]]
      end
      def deps do
        [{:warpex, "~> 1.1"}]
      end

  Configure it in `config.exs`:
      config :warpex,
        address: "http://localhost",  # defaults to System.get_env("WARP10_ADDRESS"),
        read_key:   "xxxxx",  # defaults to System.get_env("WARP10_READ_KEY")
        write_key:  "xxxxx",  # defaults to System.get_env("WARP10_WRITE_KEY")
        httpoison_opts: [timeout: 5000]  # defaults to []
  """

  @doc """
  Save a list of data

  Returns {:ok, []} or {:error, :result}.

  ## Examples

      #iex> Warpex.update([%{"labels" => "label1=anything", "name" => "metric.1.memory_available", "val" => 12, "ts" => 1521969018754000}])
      {:ok, []}

  """
  def update(data) do
    HTTP.post("/api/v0/update", HTTP.map_to_text(data, ""))
  end

  @doc """
  Fetch data

  Returns {:ok, result} or {:error, :result}.

  ## Examples

      #iex> Warpex.fetch("~metric.1.*{}", Datetime.now, Datetime.now)
      {:ok, []}

  """
  def fetch(selector, start, stop) do
    HTTP.get("/api/v0/fetch", %{
      selector: selector,
      start: DateTime.to_iso8601(start),
      stop: DateTime.to_iso8601(stop)
    })
  end

  @doc """
  Execute warpcript

  Returns {:ok, result} or {:error, :result}.
  """
  def exec_warpscript(script) do
    HTTP.post("/api/v0/exec/warpscript", script)
  end

  @doc """
  Parse a Warp10 result

  Returns {:ok, result} or {:error, :result}.

  ## Examples

      #iex> Warpex.parse_result("1521141618754000// metric.1.memory_available{host=1,.app=appName} 768209")
      #[%{"ts"=> 1521141618754000, "latlon" => "", "elev" => "", "name" => "metric.1.memory_available", "labels" => %{"host" => "1", ".app" => "appName"}, "value" => "768209" }]

  """
  def parse_result(data) do
    HTTP.parse_response(String.split(data, "\n"), %{}, [])
  end

  def get_token(key_type) do
    Application.get_key(key_type)
  end
end
