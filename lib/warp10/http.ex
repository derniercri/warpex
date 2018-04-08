defmodule Warpex.HTTP do
  alias Warpex.Application
  @moduledoc false

  def map_to_text([h | t], content) do
    map_to_text(t, "#{content}\n#{transform_item(h)}")
  end

  def map_to_text([], content) do
    content
  end

  def transform_item(%{
        "ts" => ts,
        "lat:lon" => latlon,
        "elev" => elev,
        "name" => name,
        "val" => val,
        "labels" => labels
      }) do
    "#{ts}/#{latlon}/#{elev} #{name}{#{labels}} #{val}"
  end

  def transform_item(%{"ts" => ts, "name" => name, "val" => val, "labels" => labels}) do
    transform_item(%{
      "ts" => ts,
      "name" => name,
      "val" => val,
      "labels" => labels,
      "lat:lon" => "",
      "elev" => ""
    })
  end

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
      {:ok, %HTTPoison.Response{status_code: status_code} = response}
      when status_code in 200..299 ->
        {:ok, response.body}

      {:ok, %HTTPoison.Response{status_code: status_code} = response}
      when status_code in 400..599 ->
        {:error, response.body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{reason: reason}}
    end
  end

  def parse_response([], _previous, data) do
    data
  end

  def parse_response([h | t], previous, data) do
    if h != "" do
      current = parse_row(h)

      if(current["name"] == nil) do
        current = Map.put(current, "name", previous["name"])
        current = Map.put(current, "labels", previous["labels"])
      end

      parse_response(t, current, data ++ [current])
    else
      parse_response(t, previous, data)
    end
  end

  defp parse_row(data) do
    [ts, latlon, rest] = String.split(data, "/")
    {parsedTs, ""} = Integer.parse(String.replace(ts, "=", ""))
    Map.merge(%{"ts" => parsedTs, "latlon" => latlon}, String.split(rest) |> parse_rest)
  end

  defp parse_rest([def, value]) do
    [name, rest] = String.split(def, "{")
    [labels_text, _] = String.split(rest, "}")

    labels = parse_labels(String.split(labels_text, ","), %{})

    %{"name" => name, "labels" => labels, "value" => value}
  end

  defp parse_labels([h | t], labels) do
    [key, value] = String.split(h, "=")
    labels = Map.put(labels, key, value)
    parse_labels(t, labels)
  end

  defp parse_labels([], labels) do
    labels
  end

  defp parse_rest([value]) do
    %{"value" => value}
  end
end
