defmodule Warpex.HTTP do
  alias Warpex.Application
  @moduledoc false

  defp headers(key_type) do
      [
        "X-Warp10-Token": Application.get_key(key_type),
        "Content-Type": "text/plain"
      ]
  end

  def get(endpoint, params) do
    opts = Application.httpoison_opts()
    opts = opts ++ [params: params]
    HTTPoison.get(Application.address() <> endpoint, headers(:read), opts)
    |> handle_response
  end

  def post(endpoint, data) do
    opts = Application.httpoison_opts()
    HTTPoison.post(Application.address() <> endpoint, data, headers(:write), opts)
    |> handle_response
  end

  defp handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: status_code} = response } when status_code in 200..299 ->
        {:ok, response.body }
      {:ok, %HTTPoison.Response{status_code: status_code} = response } when status_code in 400..599 ->
        {:error, response.body }
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{ reason: reason } }
    end
  end

  def parse_response([], previous, data) do
    data
  end

  def parse_response([h | t], previous, data) do
    current = parse_row(h)

    if(current["name"] == nil) do
      current = Map.put(current, "name", previous["name"])
      current = Map.put(current, "labels", previous["labels"])
    end

    parse_response(t, current, data ++ [current])        
  end

  defp parse_row("") do
    %{}
  end

  defp parse_row(data) do
    [ts, latlon, rest] = String.split(data, "/")
    {parsedTs, ""} = Integer.parse(String.replace(ts, "=", ""))
    Map.merge( %{"ts" => parsedTs, "latlon" => latlon}, String.split(rest) |> parse_rest)
  end

  defp parse_rest([def, value]) do
    [name, rest] = String.split(def, "{")
    [labels, _] = String.split(rest, "}")

    %{"name" => name, "labels" => labels, "value" => value}    
  end

  defp parse_rest([value]) do
    %{"value" => value}    
  end
end