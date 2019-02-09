defmodule Warpex.HTTP do
  alias Warpex.Application
  @moduledoc false

  alias Warpex.HTTP

  use HTTPoison.Base

  def process_url(url), do: Application.address() <> url

  def map_to_text(data) do
    Enum.reduce(data, "", &"#{&2}\n#{transform_item(&1)}")
  end

  def transform_item(item) do
    item
    |> Map.put_new("latlon", "")
    |> Map.put_new("elev", "")
    |> (fn i ->
          "#{i["ts"]}/#{i["latlon"]}/#{i["elev"]} " <> "#{i["name"]}{#{i["labels"]}} #{i["val"]}"
        end).()
  end

  defp headers(key_type) do
    [
      "X-Warp10-Token": Application.get_key(key_type),
      "Content-Type": "text/plain"
    ]
  end

  def get(endpoint, params) do
    opts = Application.httpoison_opts()
    opts = [{:params, params} | opts]

    endpoint
    |> HTTP.get(headers(:read), opts)
    |> handle_response()
  end

  def post(endpoint, data) do
    opts = Application.httpoison_opts()

    endpoint
    |> HTTP.post(data, headers(:write), opts)
    |> handle_response()
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

  def parse_response(_previous, [], data) do
    Enum.reverse(data)
  end

  def parse_response(previous, ["" | tail], data) do
    parse_response(previous, tail, data)
  end

  def parse_response(previous, [head | tail], data) do
    head
    |> parse_row()
    |> fill_current(previous)
    |> (&parse_response(&1, tail, [&1 | data])).()
  end

  defp fill_current(current, previous) do
    current =
      case Map.fetch(current, "name") do
        :error ->
          current
          |> Map.put("name", previous["name"])
          |> Map.put("labels", previous["labels"])

        {:ok, _} ->
          current
      end

    current =
      case current["latlon"] do
        "" ->
          current
          |> Map.put("latlon", previous["latlon"])

        _ ->
          current
      end

    current
  end

  defp parse_row(data) do
    {parsed_map, rest} =
      case String.split(data, "/") do
        [ts, latlon, rest] ->
          {%{
             "ts" => elem(Integer.parse(String.replace(ts, "=", "")), 0),
             "latlon" => latlon
           }, rest}
      end

    Map.merge(
      parsed_map,
      rest |> String.split() |> parse_rest()
    )
  end

  defp parse_rest([elev, def, value]) do
    Map.put(parse_rest([def, value]), "elev", elev)
  end

  defp parse_rest([def, value]) do
    [name, rest] = String.split(def, "{")
    [labels_text, _] = String.split(rest, "}")

    labels =
      labels_text
      |> String.split(",")
      |> parse_labels(%{})

    %{"name" => name, "labels" => labels, "value" => value}
  end

  defp parse_rest([value]) do
    %{"value" => value}
  end

  defp parse_labels([h | t], labels) do
    [key, value] = String.split(h, "=")
    labels = Map.put(labels, key, value)
    parse_labels(t, labels)
  end

  defp parse_labels([], labels) do
    labels
  end
end
